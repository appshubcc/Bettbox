//! The YAML grammar of the editor (`editorYamlMode`, built on the one
//! re_highlight 0.0.3 ships), one line at a time: every rule below is one of
//! its modes, tried in its order.

use super::*;

const LITERALS: [&str; 5] = ["true", "false", "yes", "no", "null"];
const DOCTAGS: [&str; 7] = ["TODO", "FIXME", "NOTE", "BUG", "OPTIMIZE", "HACK", "XXX"];
const PHRASE_WORDS: [&str; 11] = [
    "i", "a", "is", "so", "us", "to", "at", "if", "in", "it", "on",
];
const CONTRACTIONS: [&str; 7] = ["d", "ve", "re", "ll", "t", "s", "n"];

const FLAG_KEY: u8 = 1 << 0;
const FLAG_URI: u8 = 1 << 1;

const ASCII_FLAGS: [u8; 128] = {
    let mut table = [0u8; 128];
    let mut i = 0usize;
    while i < 128 {
        let b = i as u8;
        let is_w = b.is_ascii_alphanumeric() || b == b'_';
        if is_w || matches!(b, b' ' | b':' | b'/' | b'.' | b'-') {
            table[i] |= FLAG_KEY;
        }
        if is_w
            || matches!(
                b,
                b'#' | b';'
                    | b'/'
                    | b'?'
                    | b':'
                    | b'@'
                    | b'&'
                    | b'='
                    | b'+'
                    | b'$'
                    | b','
                    | b'.'
                    | b'~'
                    | b'*'
                    | b'\''
                    | b'('
                    | b')'
                    | b'['
                    | b']'
            )
        {
            table[i] |= FLAG_URI;
        }
        i += 1;
    }
    table
};

#[derive(Clone, Copy, PartialEq)]
enum Container {
    Object,
    Array,
}

struct ContainerStack {
    inline: [Container; 32],
    len: usize,
    spill: Vec<Container>,
}

impl ContainerStack {
    #[inline(always)]
    fn new() -> Self {
        Self {
            inline: [Container::Object; 32],
            len: 0,
            spill: Vec::new(),
        }
    }

    #[inline(always)]
    fn is_empty(&self) -> bool {
        self.len == 0
    }

    #[inline(always)]
    fn push(&mut self, item: Container) {
        if self.len < 32 {
            self.inline[self.len] = item;
        } else {
            self.spill.push(item);
        }
        self.len += 1;
    }

    #[inline(always)]
    fn pop(&mut self) {
        if self.len > 32 {
            self.spill.pop();
        }
        self.len -= 1;
    }

    #[inline(always)]
    fn last(&self) -> Option<Container> {
        if self.len == 0 {
            None
        } else if self.len <= 32 {
            Some(self.inline[self.len - 1])
        } else {
            self.spill.last().copied()
        }
    }
}

#[inline(always)]
fn is_key_char(ch: char) -> bool {
    if ch.is_ascii() {
        (ASCII_FLAGS[ch as usize] & FLAG_KEY) != 0
    } else {
        is_word(ch)
    }
}

#[inline(always)]
fn is_uri_char(ch: char) -> bool {
    if ch.is_ascii() {
        (ASCII_FLAGS[ch as usize] & FLAG_URI) != 0
    } else {
        is_word(ch)
    }
}

#[inline(always)]
fn run(line: &Line, from: usize, accepts: impl Fn(char) -> bool) -> usize {
    let chars = &line.chars;
    let len = chars.len();
    let mut end = from;
    while end < len && accepts(chars[end]) {
        end += 1;
    }
    end
}

#[inline(always)]
fn ends_key(line: &Line, colon: usize) -> bool {
    matches!(line.at(colon + 1), Some(' ' | '\t')) || line.ends_at(colon + 1)
}

/// `keyless` is how far a run of key characters is known to hold no key, so
/// a line of plain words is not scanned again from each of them.
fn key(line: &Line, at: usize, keyless: &mut usize) -> Option<usize> {
    let chars = &line.chars;
    let first = *chars.get(at)?;
    if is_word(first) {
        if at < *keyless {
            return None;
        }
        let end = run(line, at, is_key_char);
        let mut colon = end;
        while colon > at + 1 {
            colon -= 1;
            if chars[colon] == ':' && ends_key(line, colon) {
                return Some(colon + 1);
            }
        }
        *keyless = end;
        return None;
    }
    if first != '"' && first != '\'' {
        return None;
    }
    if !chars.get(at + 1).copied().is_some_and(is_word) {
        return None;
    }
    let end = run(line, at + 1, is_key_char);
    (chars.get(end) == Some(&first)
        && chars.get(end + 1) == Some(&':')
        && ends_key(line, end + 1))
    .then_some(end + 2)
}

/// Whether `(?<=^[ \t]*(?:-[ \t]+)*)` matches here.
fn after_indent(line: &Line, at: usize) -> bool {
    let chars = &line.chars;
    let mut start = at;
    while start > 0 && matches!(chars[start - 1], ' ' | '\t' | '-') {
        start -= 1;
    }
    if !line.starts_at(start) {
        return false;
    }
    let blank = |index: usize| matches!(chars[index], ' ' | '\t');
    let mut index = start;
    while index < at && blank(index) {
        index += 1;
    }
    while index < at {
        if chars[index] != '-' || index + 1 == at || !blank(index + 1) {
            return false;
        }
        index += 1;
        while index < at && blank(index) {
            index += 1;
        }
    }
    true
}

fn block_key(line: &Line, at: usize) -> Option<usize> {
    if !after_indent(line, at) {
        return None;
    }
    let chars = &line.chars;
    let len = chars.len();
    let quoted_key = |close: usize| {
        (close < len && line.at(close + 1) == Some(':') && ends_key(line, close + 1))
            .then_some(close + 2)
    };
    let mut index = at + 1;
    match chars[at] {
        '"' => {
            while index < len && chars[index] != '"' {
                if chars[index] == '\\' {
                    if index + 1 == len || is_line_terminator(chars[index + 1]) {
                        return None;
                    }
                    index += 1;
                }
                index += 1;
            }
            quoted_key(index)
        }
        '\'' => {
            while index < len {
                if chars[index] == '\'' {
                    if line.at(index + 1) != Some('\'') {
                        break;
                    }
                    index += 1;
                }
                index += 1;
            }
            quoted_key(index)
        }
        first
            if is_space(first)
                || matches!(
                    first,
                    '-' | '?'
                        | ':'
                        | ','
                        | '['
                        | ']'
                        | '{'
                        | '}'
                        | '#'
                        | '&'
                        | '*'
                        | '!'
                        | '|'
                        | '>'
                        | '%'
                        | '@'
                        | '`'
                ) =>
        {
            None
        }
        _ => {
            while index < len {
                match chars[index] {
                    '#' | '{' | '}' | '[' | ']' => return None,
                    ':' if ends_key(line, index) => return Some(index + 1),
                    _ => index += 1,
                }
            }
            None
        }
    }
}

fn document_marker(line: &Line, at: usize) -> Option<usize> {
    let chars = &line.chars;
    if !line.starts_at(at)
        || at + 3 > chars.len()
        || chars[at] != '-'
        || chars[at + 1] != '-'
        || chars[at + 2] != '-'
    {
        return None;
    }
    let spaces = run(line, at + 3, is_space);
    (at + 3..=spaces).rev().find(|&end| line.ends_at(end))
}

fn tag(line: &Line, at: usize) -> Option<usize> {
    let uri = |from: usize| {
        let end = run(line, from, is_uri_char);
        (end > from).then_some(end)
    };
    let handle = run(line, at + 1, is_word);
    if handle > at + 1 && line.at(handle) == Some('!') {
        if let Some(end) = uri(handle + 1) {
            return Some(end);
        }
    }
    if line.at(at + 1) == Some('<') {
        if let Some(end) = uri(at + 2) {
            if line.at(end) == Some('>') {
                return Some(end + 1);
            }
        }
    }
    if let Some(end) = uri(at + 1) {
        return Some(end);
    }
    if line.at(at + 1) == Some('!') {
        return uri(at + 2);
    }
    None
}

fn anchor(line: &Line, at: usize) -> Option<usize> {
    if !line
        .at(at + 1)
        .is_some_and(|ch| ch.is_ascii_alphabetic() || ch == '_')
    {
        return None;
    }
    let end = run(line, at + 2, is_word);
    line.ends_at(end).then_some(end)
}

fn literal(line: &Line, at: usize) -> Option<usize> {
    let chars = &line.chars;
    let first = chars[at];
    if !first.is_ascii_alphabetic() || (at > 0 && is_word(chars[at - 1])) {
        return None;
    }
    let check = |word: &str| -> Option<usize> {
        let end = at + word.len();
        (starts_with(line, at, word)
            && !chars
                .get(end)
                .copied()
                .is_some_and(|next| is_word(next) || next == '.'))
        .then_some(end)
    };
    match (first as u8).to_ascii_lowercase() {
        b't' => check(LITERALS[0]),
        b'f' => check(LITERALS[1]),
        b'y' => check(LITERALS[2]),
        b'n' => check(LITERALS[3]).or_else(|| check(LITERALS[4])),
        _ => None,
    }
}

/// Whether `\b` matches here.
#[inline(always)]
fn boundary(line: &Line, at: usize) -> bool {
    let chars = &line.chars;
    let before = at > 0 && is_word(chars[at - 1]);
    let after = chars.get(at).copied().is_some_and(is_word);
    before != after
}

#[inline(always)]
fn digit(line: &Line, at: usize) -> bool {
    line.chars.get(at).is_some_and(char::is_ascii_digit)
}

#[inline(always)]
fn digits(line: &Line, at: usize) -> usize {
    run(line, at, |ch| ch.is_ascii_digit())
}

#[inline(always)]
fn starts_with(line: &Line, at: usize, word: &str) -> bool {
    let bytes = word.as_bytes();
    let end = at + bytes.len();
    if end > line.len() {
        return false;
    }
    let slice = &line.chars[at..end];
    let mut i = 0;
    while i < bytes.len() {
        let ch = slice[i];
        if !ch.is_ascii() || (ch as u8).to_ascii_lowercase() != bytes[i] {
            return false;
        }
        i += 1;
    }
    true
}

/// `\b(?=[\s,\]}]|$)`
#[inline(always)]
fn number_ends(line: &Line, at: usize) -> bool {
    boundary(line, at)
        && line
            .at(at)
            .map_or(true, |ch| is_space(ch) || matches!(ch, ',' | ']' | '}'))
}

/// `([eE][-+]?\d+)?\b(?=[\s,\]}]|$)` from `at`, the exponent first and then
/// without it.
fn number_end(line: &Line, at: usize) -> Option<usize> {
    if matches!(line.at(at), Some('e' | 'E')) {
        let sign = at + 1 + usize::from(matches!(line.at(at + 1), Some('-' | '+')));
        let end = digits(line, sign);
        if end > sign && number_ends(line, end) {
            return Some(end);
        }
    }
    number_ends(line, at).then_some(at)
}

/// `(-?)(\b0[xX][a-fA-F0-9]+|(\b\d+(\.\d*)?|\.\d+)([eE][-+]?\d+)?)\b(?=[\s,\]}]|$)`
fn number(line: &Line, at: usize) -> Option<usize> {
    let chars = &line.chars;
    let start = at + usize::from(chars[at] == '-');
    if digit(line, start) {
        if !boundary(line, start) {
            return None;
        }
        if chars[start] == '0' && matches!(line.at(start + 1), Some('x' | 'X')) {
            let end = run(line, start + 2, |ch| ch.is_ascii_hexdigit());
            if end > start + 2 && number_ends(line, end) {
                return Some(end);
            }
        }
        let whole = digits(line, start);
        if line.at(whole) == Some('.') {
            let fraction = digits(line, whole + 1);
            let mut end = fraction;
            while end >= whole + 1 {
                if let Some(res) = number_end(line, end) {
                    return Some(res);
                }
                end -= 1;
            }
        }
        return number_end(line, whole);
    }
    if line.at(start) == Some('.') {
        let fraction = digits(line, start + 1);
        let mut end = fraction;
        while end >= start + 2 {
            if let Some(res) = number_end(line, end) {
                return Some(res);
            }
            end -= 1;
        }
    }
    None
}

#[inline(always)]
fn pair(line: &Line, at: usize, lead: char) -> bool {
    line.at(at) == Some(lead) && digit(line, at + 1) && digit(line, at + 2)
}

#[inline(always)]
fn match_zone(line: &Line, fraction: usize) -> Option<usize> {
    let blanks = run(line, fraction, |ch| ch == ' ' || ch == '\t');
    let mut blank = blanks;
    loop {
        match line.at(blank) {
            Some('Z' | 'z') => {
                if boundary(line, blank + 1) {
                    return Some(blank + 1);
                }
            }
            Some('-' | '+') if digit(line, blank + 1) => {
                for hour in [blank + 3, blank + 2] {
                    if hour == blank + 3 && !digit(line, blank + 2) {
                        continue;
                    }
                    if pair(line, hour, ':') && boundary(line, hour + 3) {
                        return Some(hour + 3);
                    }
                    if boundary(line, hour) {
                        return Some(hour);
                    }
                }
            }
            _ => {}
        }
        if boundary(line, blank) {
            return Some(blank);
        }
        if blank == fraction {
            break;
        }
        blank -= 1;
    }
    None
}

/// `\b[0-9]{4}(-[0-9][0-9]){0,2}([Tt \t][0-9][0-9]?(:[0-9][0-9]){2})?`
/// `(\.[0-9]*)?([ \t])*(Z|[-+][0-9][0-9]?(:[0-9][0-9])?)?\b`, each part
/// taken as far as it goes first and then shorter, as the pattern backtracks.
fn timestamp(line: &Line, at: usize) -> Option<usize> {
    if !boundary(line, at) || digits(line, at) < at + 4 {
        return None;
    }
    let year = at + 4;
    let mut dates = [0usize; 3];
    let mut dates_len = 0;
    if pair(line, year, '-') {
        if pair(line, year + 3, '-') {
            dates[dates_len] = year + 6;
            dates_len += 1;
        }
        dates[dates_len] = year + 3;
        dates_len += 1;
    }
    dates[dates_len] = year;
    dates_len += 1;

    for &date in &dates[..dates_len] {
        let mut times = [0usize; 3];
        let mut times_len = 0;
        if matches!(line.at(date), Some('T' | 't' | ' ' | '\t')) && digit(line, date + 1) {
            for hour in [date + 3, date + 2] {
                if (hour == date + 2 || digit(line, date + 2))
                    && pair(line, hour, ':')
                    && pair(line, hour + 3, ':')
                {
                    times[times_len] = hour + 6;
                    times_len += 1;
                }
            }
        }
        times[times_len] = date;
        times_len += 1;

        for &time in &times[..times_len] {
            if line.at(time) == Some('.') {
                let max_frac = digits(line, time + 1);
                let mut frac = max_frac;
                while frac >= time + 1 {
                    if let Some(end) = match_zone(line, frac) {
                        return Some(end);
                    }
                    frac -= 1;
                }
            }
            if let Some(end) = match_zone(line, time) {
                return Some(end);
            }
        }
    }
    None
}

#[inline(always)]
fn letters(line: &Line, at: usize, to: usize) -> usize {
    let chars = &line.chars;
    let mut end = at;
    while end < to && chars[end].is_ascii_alphabetic() {
        end += 1;
    }
    end
}

#[inline(always)]
fn try_phrase_tail(line: &Line, word: usize, to: usize, count: usize) -> Option<usize> {
    let chars = &line.chars;
    let is = |index: usize, ch: char| index < to && chars[index] == ch;
    let dots: &[usize] = if is(word, '.') { &[1, 0] } else { &[0] };
    for &dot in dots {
        let colons: &[usize] = if is(word + dot, ':') { &[1, 0] } else { &[0] };
        for &colon in colons {
            let tail = word + dot + colon;
            if is(tail, '.') && is(tail + 1, ' ') {
                if let Some(end) = phrase_words(line, tail + 2, to, count - 1) {
                    return Some(end);
                }
            }
            if is(tail, ' ') {
                if let Some(end) = phrase_words(line, tail + 1, to, count - 1) {
                    return Some(end);
                }
            }
        }
    }
    None
}

/// `((?:word)[.]?[:]?([.][ ]|[ ])){count}` from `at`.
fn phrase_words(line: &Line, at: usize, to: usize, count: usize) -> Option<usize> {
    if count == 0 {
        return Some(at);
    }
    for word in PHRASE_WORDS {
        let end = at + word.len();
        if end <= to && starts_with(line, at, word) {
            if let Some(res) = try_phrase_tail(line, end, to, count) {
                return Some(res);
            }
        }
    }
    let word = letters(line, at, to);
    if word > at {
        let chars = &line.chars;
        if word < to && chars[word] == '\'' {
            for suffix in CONTRACTIONS {
                let end = word + 1 + suffix.len();
                if end <= to && starts_with(line, word + 1, suffix) {
                    if let Some(res) = try_phrase_tail(line, end, to, count) {
                        return Some(res);
                    }
                }
            }
        }
        if word < to && chars[word] == '-' {
            let max_end = letters(line, word + 1, to);
            let mut end = max_end;
            while end >= word + 2 {
                if let Some(res) = try_phrase_tail(line, end, to, count) {
                    return Some(res);
                }
                end -= 1;
            }
        }
        let mut end = word;
        while end >= at + 3 {
            if let Some(res) = try_phrase_tail(line, end, to, count) {
                return Some(res);
            }
            end -= 1;
        }
    }
    None
}

/// The first run of spaces up to `limit` that three such words follow, and where they end.
fn phrase_before(line: &Line, from: usize, limit: usize, to: usize) -> Option<(usize, usize)> {
    let chars = &line.chars;
    let mut at = from;
    while at < limit {
        if chars[at] != ' ' {
            at += 1;
            continue;
        }
        let mut words = at;
        while words < to && chars[words] == ' ' {
            words += 1;
        }
        if let Some(end) = phrase_words(line, words, to, 3) {
            return Some((at, end));
        }
        at = words;
    }
    None
}

#[inline(always)]
fn find(line: &Line, from: usize, to: usize, text: &str) -> Option<usize> {
    let needle = text.as_bytes();
    let n = needle.len();
    if n == 0 || to < n || from > to - n {
        return None;
    }
    let chars = &line.chars;
    let limit = to - n;
    let first = needle[0] as char;
    let mut at = from;
    'outer: while at <= limit {
        if chars[at] == first {
            let mut i = 1;
            while i < n {
                if chars[at + i] != needle[i] as char {
                    at += 1;
                    continue 'outer;
                }
                i += 1;
            }
            return Some(at);
        }
        at += 1;
    }
    None
}

fn doctag(line: &Line, from: usize, to: usize) -> Option<(usize, usize, usize)> {
    let chars = &line.chars;
    for at in from..to {
        let first = chars[at];
        if !first.is_ascii_alphabetic() {
            continue;
        }
        let candidate = match (first as u8).to_ascii_uppercase() {
            b'T' => DOCTAGS[0],
            b'F' => DOCTAGS[1],
            b'N' => DOCTAGS[2],
            b'B' => DOCTAGS[3],
            b'O' => DOCTAGS[4],
            b'H' => DOCTAGS[5],
            b'X' => DOCTAGS[6],
            _ => continue,
        };
        let bytes = candidate.as_bytes();
        let end = at + bytes.len();
        if end < to && chars[end] == ':' {
            let slice = &chars[at..end];
            let mut matched = true;
            let mut i = 1;
            while i < bytes.len() {
                let ch = slice[i];
                if !ch.is_ascii() || (ch as u8).to_ascii_uppercase() != bytes[i] {
                    matched = false;
                    break;
                }
                i += 1;
            }
            if matched {
                let mut begin = at;
                while begin > from && chars[begin - 1] == ' ' {
                    begin -= 1;
                }
                return Some((begin, at, end + 1));
            }
        }
    }
    None
}

fn comment(line: &mut Line, at: usize) -> usize {
    let end = (at + 1..=line.len())
        .find(|&index| line.ends_at(index))
        .unwrap_or(line.len());
    let mut emitted = at;
    let mut cursor = at + 1;
    while let Some((begin, start, stop)) = doctag(line, cursor, end) {
        if let Some((_, phrase_stop)) = phrase_before(line, cursor, begin, end) {
            cursor = phrase_stop;
        } else {
            line.emit(COMMENT, emitted, start);
            line.emit(DOCTAG, start, stop);
            emitted = stop;
            cursor = stop;
        }
    }
    line.emit(COMMENT, emitted, end);
    end
}

/// A `{{ }}` or `%{ }` inside a string: where it ends, or the end of the
/// line when it never closes and so takes the rest of the line with it.
fn template(line: &mut Line, at: usize) -> Option<(usize, bool)> {
    let close = match (line.at(at), line.at(at + 1)) {
        (Some('{'), Some('{')) => "}}",
        (Some('%'), Some('{')) => "}",
        _ => return None,
    };
    let found = find(line, at + 2, line.len(), close);
    let end = found.map_or(line.len(), |start| start + close.len());
    line.emit(TEMPLATE_VARIABLE, at, end);
    Some((end, found.is_some()))
}

fn quoted(line: &mut Line, at: usize) -> usize {
    let quote = line.chars[at];
    let len = line.len();
    let mut start = at;
    let mut cursor = at + 1;
    while cursor < len {
        let ch = line.chars[cursor];
        if ch == '\\' && cursor + 1 < len {
            cursor += 2;
        } else if ch == quote {
            line.emit(STRING, start, cursor + 1);
            return cursor + 1;
        } else if ch == '{' || ch == '%' {
            let before = line.tokens_len();
            match template(line, cursor) {
                Some((end, closed)) => {
                    line.insert(before, STRING, start, cursor);
                    if !closed {
                        return end;
                    }
                    start = end;
                    cursor = end;
                }
                None => cursor += 1,
            }
        } else {
            cursor += 1;
        }
    }
    line.emit(STRING, start, len);
    len
}

fn plain(line: &mut Line, at: usize, contained: bool) -> usize {
    let mut cursor = if contained {
        run(line, at, |ch| {
            !is_space(ch) && !matches!(ch, ',' | '{' | '}' | '[' | ']')
        })
    } else {
        run(line, at, |ch| !is_space(ch))
    };
    line.emit(STRING, at, cursor);
    let len = line.len();
    loop {
        if line.at(cursor) == Some('\\') && cursor + 1 < len {
            line.emit(STRING, cursor, cursor + 2);
            cursor += 2;
            continue;
        }
        match template(line, cursor) {
            Some((end, true)) => cursor = end,
            Some((end, false)) => return end,
            None => return cursor,
        }
    }
}

pub fn highlight(text: &str) -> Vec<u32> {
    let mut line = Line::new(text);
    let len = line.len();
    if len == 0 {
        return line.finish();
    }
    let mut containers = ContainerStack::new();
    let mut keyless = 0;
    let mut at = 0;
    while at < len {
        let ch = line.chars[at];
        if is_space(ch) {
            at += 1;
            continue;
        }
        if let Some(container) = containers.last() {
            let closes = match ch {
                '}' => Some(Container::Object),
                ']' => Some(Container::Array),
                _ => None,
            };
            if ch == ',' || closes.is_some() {
                if closes == Some(container) {
                    containers.pop();
                }
                at += 1;
                continue;
            }
        }
        let attr = if containers.is_empty() {
            block_key(&line, at)
        } else {
            key(&line, at, &mut keyless)
        };
        if let Some(end) = attr {
            line.emit(ATTR, at, end);
            at = end;
            continue;
        }
        let next = line.at(at + 1);
        let token = match ch {
            '-' => document_marker(&line, at).map(|end| (META, end)).or_else(|| {
                (next == Some(' ') || line.ends_at(at + 1)).then_some((BULLET, at + 1))
            }),
            '!' => tag(&line, at).map(|end| (TYPE, end)),
            '&' | '*' => anchor(&line, at).map(|end| (META, end)),
            _ => None,
        };
        if let Some((scope, end)) = token {
            line.emit(scope, at, end);
            at = end;
            continue;
        }
        if ch == '<' && next == Some('%') {
            let begin = at + 2 + usize::from(matches!(line.at(at + 2), Some('%' | '=' | '-')));
            at = find(&line, begin, len, "%>").map_or(len, |found| found + 2);
            continue;
        }
        if ch == '#' {
            if !containers.is_empty() {
                at = comment(&mut line, at);
                continue;
            }
            if at == 0 || is_space(line.chars[at - 1]) {
                let end = (at + 1..=len)
                    .find(|&index| line.ends_at(index))
                    .unwrap_or(len);
                line.emit(COMMENT, at, end);
                at = end;
                continue;
            }
        }
        if let Some(end) = literal(&line, at) {
            if at == 0 || line.chars[at - 1] != '.' {
                line.emit(LITERAL, at, end);
                at = end;
                continue;
            }
        }
        if let Some(end) = timestamp(&line, at).or_else(|| number(&line, at)) {
            line.emit(NUMBER, at, end);
            at = end;
            continue;
        }
        at = match ch {
            '{' => {
                containers.push(Container::Object);
                at + 1
            }
            '[' => {
                containers.push(Container::Array);
                at + 1
            }
            '\'' | '"' => quoted(&mut line, at),
            _ => plain(&mut line, at, !containers.is_empty()),
        };
    }
    line.finish()
}
