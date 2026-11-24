//! The matching loop of highlight.js as re_highlight 0.0.3 runs it, over a
//! grammar that package compiled and `highlight_grammar_test.dart` exported.
//! Anything the loop cannot do as that package does gives `None`, and the
//! caller falls back to the package for that line.

use fancy_regex::Regex;
use serde_json::Value;
use std::cell::{Cell, RefCell};
use std::collections::HashMap;
use std::hash::{BuildHasherDefault, Hasher};
use std::rc::Rc;

const SPACE: &str = r"\t\n\x0B\x0C\r \x{a0}\x{1680}\x{2000}-\x{200a}\x{2028}\x{2029}\x{202f}\x{205f}\x{3000}\x{feff}";
const WORD: &str = "A-Za-z0-9_";
const TERMINATOR: &str = r"\n\r\x{2028}\x{2029}";

/// A JavaScript pattern without the `u` flag as a pattern of this crate's
/// engine, where `\w`, `\d`, `\s` and `\b` would otherwise be Unicode-aware.
fn translate(source: &str) -> Option<String> {
    let mut chars = source.chars().peekable();
    let mut out = String::with_capacity(source.len() * 2);
    let mut in_class = false;
    while let Some(ch) = chars.next() {
        if ch == '\\' {
            let escaped = chars.next()?;
            match (escaped, in_class) {
                ('d', false) => out.push_str("[0-9]"),
                ('d', true) => out.push_str("0-9"),
                ('w', false) => out.push_str(&format!("[{WORD}]")),
                ('w', true) => out.push_str(WORD),
                ('s', false) => out.push_str(&format!("[{SPACE}]")),
                ('s', true) => out.push_str(SPACE),
                ('S', false) => out.push_str(&format!("[^{SPACE}]")),
                ('W', false) => out.push_str(&format!("[^{WORD}]")),
                ('D', false) => out.push_str("[^0-9]"),
                ('b', false) => out.push_str(&format!(
                    "(?:(?<=[{WORD}])(?![{WORD}])|(?<![{WORD}])(?=[{WORD}]))"
                )),
                ('B', false) => out.push_str(&format!(
                    "(?:(?<=[{WORD}])(?=[{WORD}])|(?<![{WORD}])(?![{WORD}]))"
                )),
                ('S', true) => out.push_str(&format!("[^{SPACE}]")),
                ('W', true) => out.push_str(&format!("[^{WORD}]")),
                ('D', true) => out.push_str("[^0-9]"),
                ('b' | 'B', true) => return None,
                _ => {
                    out.push('\\');
                    out.push(escaped);
                }
            }
        } else if in_class {
            match ch {
                ']' => {
                    in_class = false;
                    out.push(']');
                }
                '[' | '&' | '~' => {
                    out.push('\\');
                    out.push(ch);
                }
                _ => out.push(ch),
            }
        } else {
            match ch {
                '[' => {
                    in_class = true;
                    out.push('[');
                    if chars.next_if_eq(&'^').is_some() {
                        out.push('^');
                    }
                }
                '.' => out.push_str(&format!("[^{TERMINATOR}]")),
                '^' => out.push_str(&format!(r"(?:\A|(?<=[{TERMINATOR}]))")),
                '$' => out.push_str(&format!(r"(?=[{TERMINATOR}]|\z)")),
                _ => out.push(ch),
            }
        }
    }
    Some(out)
}

fn count_groups(pattern: &str) -> usize {
    let bytes = pattern.as_bytes();
    let mut count = 0;
    let mut in_class = false;
    let mut at = 0;
    while at < bytes.len() {
        match bytes[at] {
            b'\\' => at += 1,
            b'[' if !in_class => in_class = true,
            b']' if in_class => in_class = false,
            b'(' if !in_class && bytes.get(at + 1) != Some(&b'?') => count += 1,
            _ => {}
        }
        at += 1;
    }
    count
}

/// The characters a pattern's match can start with: the ASCII ones, whether
/// any other, and whether it can match nothing at all. Wider than the truth
/// wherever the pattern is not worth following, never narrower.
#[derive(Clone)]
struct First {
    ascii: [bool; 128],
    other: bool,
    empty: bool,
}

impl First {
    fn none() -> Self {
        Self {
            ascii: [false; 128],
            other: false,
            empty: false,
        }
    }

    fn any() -> Self {
        Self {
            ascii: [true; 128],
            other: true,
            empty: true,
        }
    }

    fn of(accepts: impl Fn(char) -> bool, other: bool) -> Self {
        let mut first = Self::none();
        for code in 0..128u8 {
            first.ascii[code as usize] = accepts(code as char);
        }
        first.other = other;
        first
    }

    fn add(&mut self, more: &First) {
        for (mine, theirs) in self.ascii.iter_mut().zip(more.ascii) {
            *mine |= theirs;
        }
        self.other |= more.other;
    }

    fn inverted(&self) -> Self {
        let mut first = Self::none();
        for (mine, theirs) in first.ascii.iter_mut().zip(self.ascii) {
            *mine = !theirs;
        }
        first.other = true;
        first
    }

    fn accepts(&self, key: usize) -> bool {
        self.empty
            || match key {
                0..=127 => self.ascii[key],
                128 => self.other,
                _ => false,
            }
    }
}

struct FirstParser {
    chars: Vec<char>,
    at: usize,
}

impl FirstParser {
    fn escape(&mut self) -> Option<First> {
        let escaped = *self.chars.get(self.at)?;
        self.at += 1;
        let ascii_space = |ch: char| matches!(ch, '\t' | '\n' | '\u{b}' | '\u{c}' | '\r' | ' ');
        Some(match escaped {
            'd' => First::of(|ch| ch.is_ascii_digit(), false),
            'w' => First::of(super::is_word, false),
            's' => First::of(ascii_space, true),
            'D' => First::of(|ch| ch.is_ascii_digit(), false).inverted(),
            'W' => First::of(super::is_word, false).inverted(),
            'S' => First::of(ascii_space, true).inverted(),
            't' => First::of(|ch| ch == '\t', false),
            'n' => First::of(|ch| ch == '\n', false),
            'r' => First::of(|ch| ch == '\r', false),
            _ if escaped.is_ascii_alphanumeric() => return None,
            _ => First::of(|ch| ch == escaped, !escaped.is_ascii()),
        })
    }

    fn class(&mut self) -> Option<First> {
        let negated = self.chars.get(self.at) == Some(&'^');
        if negated {
            self.at += 1;
        }
        let mut first = First::none();
        loop {
            let ch = *self.chars.get(self.at)?;
            self.at += 1;
            if ch == ']' {
                break;
            }
            let (item, single) = if ch == '\\' {
                let escaped = *self.chars.get(self.at)?;
                (
                    self.escape()?,
                    (!escaped.is_ascii_alphanumeric()).then_some(escaped),
                )
            } else {
                (First::of(|other| other == ch, !ch.is_ascii()), Some(ch))
            };
            let ranged = self.chars.get(self.at) == Some(&'-')
                && self.chars.get(self.at + 1).is_some_and(|&next| next != ']');
            if !ranged {
                first.add(&item);
                continue;
            }
            let low = single?;
            self.at += 1;
            let mut high = *self.chars.get(self.at)?;
            self.at += 1;
            if high == '\\' {
                high = *self.chars.get(self.at)?;
                self.at += 1;
                if high.is_ascii_alphanumeric() {
                    return None;
                }
            }
            first.add(&First::of(
                |other| low <= other && other <= high,
                !high.is_ascii(),
            ));
        }
        Some(if negated { first.inverted() } else { first })
    }

    /// An atom with its quantifier: what it starts with and whether it can
    /// be empty.
    fn atom(&mut self) -> Option<(First, bool)> {
        let ch = *self.chars.get(self.at)?;
        self.at += 1;
        let (first, mut empty) = match ch {
            '(' => {
                let ahead = self.chars.get(self.at) == Some(&'?');
                let kind = self.chars.get(self.at + 1).copied();
                if ahead {
                    if !matches!(kind, Some(':' | '=' | '!')) {
                        return None;
                    }
                    self.at += 2;
                }
                let inner = self.alternation()?;
                if self.chars.get(self.at) != Some(&')') {
                    return None;
                }
                self.at += 1;
                if ahead && kind != Some(':') {
                    (First::none(), true)
                } else {
                    let empty = inner.empty;
                    (inner, empty)
                }
            }
            '[' => (self.class()?, false),
            '\\' => match self.chars.get(self.at) {
                Some('b' | 'B') => {
                    self.at += 1;
                    (First::none(), true)
                }
                _ => (self.escape()?, false),
            },
            '.' => (
                First::of(|other| !super::is_line_terminator(other), true),
                false,
            ),
            '^' | '$' => (First::none(), true),
            '*' | '+' | '?' | '{' | ')' | '|' => return None,
            _ => (First::of(|other| other == ch, !ch.is_ascii()), false),
        };
        match self.chars.get(self.at) {
            Some('*' | '?') => {
                self.at += 1;
                empty = true;
            }
            Some('+') => self.at += 1,
            Some('{') => {
                let close = self.chars[self.at..].iter().position(|&ch| ch == '}')?;
                let bounds: String = self.chars[self.at + 1..self.at + close].iter().collect();
                let least = bounds.split(',').next()?;
                if least.is_empty() || least.parse::<u32>().ok()? == 0 {
                    empty = true;
                }
                self.at += close + 1;
            }
            _ => {}
        }
        if self.chars.get(self.at) == Some(&'?') {
            self.at += 1;
        }
        Some((first, empty))
    }

    fn alternation(&mut self) -> Option<First> {
        let mut first = First::none();
        loop {
            let mut open = true;
            while !matches!(self.chars.get(self.at), None | Some(')' | '|')) {
                let (atom, empty) = self.atom()?;
                if open {
                    first.add(&atom);
                    open = empty;
                }
            }
            first.empty |= open;
            if self.chars.get(self.at) != Some(&'|') {
                return Some(first);
            }
            self.at += 1;
        }
    }
}

fn first_of(source: &str) -> First {
    let mut parser = FirstParser {
        chars: source.chars().collect(),
        at: 0,
    };
    match parser.alternation() {
        Some(first) if parser.at == parser.chars.len() => first,
        _ => First::any(),
    }
}

fn is_js_space(ch: char) -> bool {
    super::is_space(ch)
}

fn utf16_len(text: &str) -> usize {
    if text.is_ascii() {
        return text.len();
    }
    text.bytes()
        .map(|byte| usize::from((byte & 0xC0) != 0x80) + usize::from(byte >= 0xF0))
        .sum()
}

#[derive(Default)]
struct IndexHasher(u64);

impl Hasher for IndexHasher {
    fn finish(&self) -> u64 {
        self.0
    }

    fn write(&mut self, bytes: &[u8]) {
        for &byte in bytes {
            self.write_u64(u64::from(byte));
        }
    }

    fn write_u64(&mut self, value: u64) {
        self.0 = (self.0.rotate_left(5) ^ value).wrapping_mul(0x517c_c1b7_2722_0a95);
    }

    fn write_usize(&mut self, value: usize) {
        self.write_u64(value as u64);
    }
}

#[derive(Clone, Copy, PartialEq)]
enum Kind {
    Begin,
    End,
    Illegal,
}

struct Rule {
    pattern: String,
    first: First,
    groups: usize,
    kind: Kind,
    mode: Option<usize>,
}

struct Scope {
    wrap: Option<u32>,
    multi: bool,
    emit: HashMap<usize, bool>,
    positions: HashMap<usize, Option<u32>>,
}

#[derive(Clone, Copy)]
enum Callback {
    Jsx,
    Shebang,
}

/// Some of a mode's rules as one pattern, anchored where a search starts.
/// An empty last alternative makes it match there whatever the rules do, as
/// a search that fails goes on to try every later start.
struct Multi {
    /// For a search from the start of the text.
    head: Regex,
    /// For a search from one character into the text it is given, so that
    /// what looks behind sees the character before.
    tail: Regex,
    /// The outer group of each rule and its index among the mode's rules.
    rules: Vec<(usize, usize)>,
}

const END_OF_TEXT: usize = 129;

type CandidateMap = HashMap<(usize, usize), Option<Rc<Multi>>, BuildHasherDefault<IndexHasher>>;

struct Mode {
    scope: Option<u32>,
    has_scope: bool,
    begin_scope: Option<Scope>,
    end_scope: Option<Scope>,
    keywords: Option<HashMap<String, Option<u32>>>,
    keyword_pattern: Option<Regex>,
    end: Option<Regex>,
    skip: Option<bool>,
    exclude_begin: bool,
    exclude_end: bool,
    return_begin: bool,
    return_end: bool,
    ends_with_parent: bool,
    ends_parent: bool,
    sub_language: bool,
    before_begin: bool,
    on_begin: Option<Callback>,
    starts: Option<usize>,
    count: usize,
    rules: Vec<Rule>,
    /// By the rules they hold.
    matchers: RefCell<HashMap<Vec<usize>, Rc<Multi>>>,
    /// By the first rule considered and the character searched from.
    candidates: RefCell<CandidateMap>,
    regex_index: Cell<usize>,
}

pub struct Grammar {
    modes: Vec<Mode>,
    scopes: Vec<String>,
}

struct Found {
    start: usize,
    end: usize,
    groups: Vec<Option<(usize, usize)>>,
    rule: usize,
    position: usize,
}

impl Grammar {
    pub fn parse(json: &str) -> Option<Self> {
        let root: Value = serde_json::from_str(json).ok()?;
        if root["caseInsensitive"].as_bool()? || root["unicodeRegex"].as_bool()? {
            return None;
        }
        let aliases = root["aliases"].as_object()?;
        let mut scopes: Vec<String> = Vec::new();
        let mut intern = |name: &str| -> u32 {
            let name = aliases.get(name).and_then(Value::as_str).unwrap_or(name);
            match scopes.iter().position(|known| known == name) {
                Some(index) => index as u32,
                None => {
                    scopes.push(name.to_string());
                    scopes.len() as u32 - 1
                }
            }
        };
        let mut modes = Vec::new();
        for mode in root["modes"].as_array()? {
            let mut scope_of = |value: &Value| -> Option<Option<Scope>> {
                if value.is_null() {
                    return Some(None);
                }
                let mut emit = HashMap::new();
                for (key, flag) in value["emit"].as_object()? {
                    emit.insert(key.parse().ok()?, flag.as_bool()?);
                }
                let mut positions = HashMap::new();
                for (key, name) in value["positions"].as_object()? {
                    positions.insert(key.parse().ok()?, name.as_str().map(&mut intern));
                }
                Some(Some(Scope {
                    wrap: value["wrap"]
                        .as_str()
                        .filter(|wrap| !wrap.is_empty())
                        .map(&mut intern),
                    multi: value["multi"].as_bool()?,
                    emit,
                    positions,
                }))
            };
            let begin_scope = scope_of(&mode["beginScope"])?;
            let end_scope = scope_of(&mode["endScope"])?;
            let keywords = match mode["keywords"].as_object() {
                Some(words) => Some(
                    words
                        .iter()
                        .map(|(word, kind)| {
                            let kind = kind.as_str()?;
                            Some((word.clone(), (!kind.starts_with('_')).then(|| intern(kind))))
                        })
                        .collect::<Option<HashMap<_, _>>>()?,
                ),
                None => None,
            };
            let compile = |value: &Value, anchored: bool| -> Option<Option<Regex>> {
                let Some(source) = value.as_str() else {
                    return Some(None);
                };
                let pattern = translate(source)?;
                let pattern = if anchored {
                    format!(r"\A(?:({pattern})|())")
                } else {
                    pattern
                };
                Some(Some(Regex::new(&pattern).ok()?))
            };
            let mut rules = Vec::new();
            for rule in mode["rules"].as_array()? {
                let pattern = translate(rule[0].as_str()?)?;
                rules.push(Rule {
                    first: first_of(rule[0].as_str()?),
                    groups: count_groups(&pattern),
                    pattern,
                    kind: match rule[1].as_str()? {
                        "begin" => Kind::Begin,
                        "end" => Kind::End,
                        "illegal" => Kind::Illegal,
                        _ => return None,
                    },
                    mode: rule[2].as_u64().map(|id| id as usize),
                });
            }
            modes.push(Mode {
                scope: mode["scope"].as_str().map(&mut intern),
                has_scope: mode["hasScope"].as_bool()?,
                begin_scope,
                end_scope,
                keywords,
                keyword_pattern: compile(&mode["keywordPattern"], false)?,
                end: compile(&mode["end"], true)?,
                skip: mode["skip"].as_bool(),
                exclude_begin: mode["excludeBegin"].as_bool()?,
                exclude_end: mode["excludeEnd"].as_bool()?,
                return_begin: mode["returnBegin"].as_bool()?,
                return_end: mode["returnEnd"].as_bool()?,
                ends_with_parent: mode["endsWithParent"].as_bool()?,
                ends_parent: mode["endsParent"].as_bool()?,
                sub_language: mode["subLanguage"].as_bool()?,
                before_begin: mode["beforeBegin"].as_bool()?,
                on_begin: match mode["onBegin"].as_str() {
                    Some("jsx") => Some(Callback::Jsx),
                    Some("shebang") => Some(Callback::Shebang),
                    Some(_) => return None,
                    None => None,
                },
                starts: mode["starts"].as_u64().map(|id| id as usize),
                count: mode["count"].as_u64()? as usize,
                rules,
                matchers: RefCell::new(HashMap::new()),
                candidates: RefCell::new(CandidateMap::default()),
                regex_index: Cell::new(0),
            });
        }
        Some(Self { modes, scopes })
    }

    pub fn scopes(&self) -> &[String] {
        &self.scopes
    }

    /// The rules from `start_at` on that can match at a character of class
    /// `key`, in their order; `None` inside when there are none.
    fn matcher(&self, mode: usize, start_at: usize, key: usize) -> Option<Option<Rc<Multi>>> {
        let mode = &self.modes[mode];
        if let Some(known) = mode.candidates.borrow().get(&(start_at, key)) {
            return Some(known.clone());
        }
        let indexes: Vec<usize> = (start_at..mode.rules.len())
            .filter(|&index| mode.rules[index].first.accepts(key))
            .collect();
        let multi = if indexes.is_empty() {
            None
        } else if let Some(known) = mode.matchers.borrow().get(&indexes) {
            Some(known.clone())
        } else {
            let mut pattern = String::new();
            let mut rules = Vec::new();
            let mut group = 1;
            for &index in &indexes {
                let rule = &mode.rules[index];
                if !pattern.is_empty() {
                    pattern.push('|');
                }
                pattern.push('(');
                pattern.push_str(&rule.pattern);
                pattern.push(')');
                rules.push((group, index));
                group += rule.groups + 1;
            }
            Some(Rc::new(Multi {
                head: Regex::new(&format!(r"\A(?:{pattern}|())")).ok()?,
                tail: Regex::new(&format!(r"\A(?s:.)(?:{pattern}|())")).ok()?,
                rules,
            }))
        };
        if let Some(multi) = &multi {
            mode.matchers.borrow_mut().insert(indexes, multi.clone());
        }
        mode.candidates
            .borrow_mut()
            .insert((start_at, key), multi.clone());
        Some(multi)
    }

    /// The first match at or after `from` of the rules from `start_at` on:
    /// at each character the first rule that matches there, as the one
    /// pattern re_highlight joins them into finds it.
    fn exec_multi(
        &self,
        mode: usize,
        start_at: usize,
        text: &str,
        from: usize,
    ) -> Option<Option<Found>> {
        let mut at = from;
        let mut before = text[..from].chars().next_back().map_or(0, char::len_utf8);
        loop {
            let next = text[at..].chars().next();
            let key = match next {
                None => END_OF_TEXT,
                Some(ch) if ch.is_ascii() => ch as usize,
                Some(_) => 128,
            };
            if let Some(multi) = self.matcher(mode, start_at, key)? {
                let base = at - before;
                let regex = if at == 0 { &multi.head } else { &multi.tail };
                if let Some(captures) = regex.captures(&text[base..]).ok()? {
                    for &(group, rule) in &multi.rules {
                        let Some(outer) = captures.get(group) else {
                            continue;
                        };
                        let count = self.modes[mode].rules[rule].groups;
                        return Some(Some(Found {
                            start: base + outer.start(),
                            end: base + outer.end(),
                            groups: (group..=group + count)
                                .map(|index| {
                                    captures
                                        .get(index)
                                        .map(|found| (base + found.start(), base + found.end()))
                                })
                                .collect(),
                            rule,
                            position: rule - start_at,
                        }));
                    }
                }
            }
            let Some(next) = next else {
                return Some(None);
            };
            before = next.len_utf8();
            at += before;
        }
    }

    /// The next match of the mode's rules, resuming after an ignored one as
    /// `_ResumableMultiRegex` does.
    fn exec(&self, mode: usize, text: &str, from: usize) -> Option<Option<Found>> {
        let state = &self.modes[mode].regex_index;
        let mut found = self.exec_multi(mode, state.get(), text, from)?;
        if state.get() != 0 && !found.as_ref().is_some_and(|found| found.start == from) {
            let next = from + text[from..].chars().next()?.len_utf8();
            found = self.exec_multi(mode, 0, text, next)?;
        }
        if let Some(found) = &found {
            state.set(state.get() + found.position + 1);
            if state.get() == self.modes[mode].count {
                state.set(0);
            }
        }
        Some(found)
    }

    pub fn highlight(&self, text: &str) -> Option<Vec<u32>> {
        let mut stack = Vec::with_capacity(8);
        stack.push(0);
        let mut nodes = Vec::with_capacity(8);
        nodes.push(None);
        Run {
            grammar: self,
            text,
            text_is_ascii: text.is_ascii(),
            stack,
            buffer: String::with_capacity(text.len()),
            nodes,
            runs: Vec::with_capacity(8),
            last: None,
            resume: false,
        }
        .run()
    }
}

struct Run<'a> {
    grammar: &'a Grammar,
    text: &'a str,
    text_is_ascii: bool,
    stack: Vec<usize>,
    buffer: String,
    nodes: Vec<Option<u32>>,
    runs: Vec<(Option<u32>, u32)>,
    last: Option<(Kind, usize)>,
    resume: bool,
}

const NO_MATCH: usize = usize::MAX;

impl Run<'_> {
    fn top(&self) -> &Mode {
        &self.grammar.modes[*self.stack.last().expect("mode stack")]
    }

    fn add_text(&mut self, text: &str) {
        if text.is_empty() {
            return;
        }
        let scope = *self.nodes.last().expect("node stack");
        let units = if self.text_is_ascii {
            text.len() as u32
        } else {
            utf16_len(text) as u32
        };
        match self.runs.last_mut() {
            Some((last, length)) if *last == scope => *length += units,
            _ => self.runs.push((scope, units)),
        }
    }

    fn close_node(&mut self) {
        if self.nodes.len() > 1 {
            self.nodes.pop();
        }
    }

    fn emit_keyword(&mut self, text: &str, scope: u32) {
        if text.is_empty() {
            return;
        }
        self.nodes.push(Some(scope));
        self.add_text(text);
        self.close_node();
    }

    fn process_keywords(&mut self) -> Option<()> {
        let mut buffer = std::mem::take(&mut self.buffer);
        let result = self.scan_keywords(&buffer);
        buffer.clear();
        self.buffer = buffer;
        result
    }

    fn scan_keywords(&mut self, buffer: &str) -> Option<()> {
        let mode = *self.stack.last()?;
        let mode = &self.grammar.modes[mode];
        let (Some(keywords), Some(pattern)) = (&mode.keywords, &mode.keyword_pattern) else {
            self.add_text(buffer);
            return Some(());
        };
        let mut pending = 0;
        let mut last = 0;
        while let Some(found) = pattern.find_from_pos(buffer, last).ok()? {
            match keywords.get(found.as_str()) {
                Some(Some(scope)) => {
                    self.add_text(&buffer[pending..found.start()]);
                    self.emit_keyword(found.as_str(), *scope);
                    pending = found.end();
                }
                Some(None) => {
                    self.add_text(&buffer[pending..found.start()]);
                    pending = found.start();
                }
                None => {}
            }
            if found.end() == found.start() {
                return None;
            }
            last = found.end();
        }
        self.add_text(&buffer[pending..]);
        Some(())
    }

    fn process_buffer(&mut self) -> Option<()> {
        if self.top().sub_language {
            let mut buffer = std::mem::take(&mut self.buffer);
            self.add_text(&buffer);
            buffer.clear();
            self.buffer = buffer;
            return Some(());
        }
        self.process_keywords()
    }

    fn emit_multi(&mut self, scope: &Scope, found: &Found) -> Option<()> {
        for index in 1..found.groups.len() {
            if scope.emit.get(&index) != Some(&true) {
                continue;
            }
            let (start, end) = found.groups[index]?;
            let text = &self.text[start..end];
            match scope.positions.get(&index).copied().flatten() {
                Some(class) => self.emit_keyword(text, class),
                None => {
                    self.buffer.clear();
                    self.buffer.push_str(text);
                    self.process_keywords()?;
                }
            }
        }
        Some(())
    }

    fn start_mode(&mut self, mode: usize, found: &Found) -> Option<()> {
        let grammar = self.grammar;
        let definition = &grammar.modes[mode];
        if let Some(scope) = definition.scope {
            self.nodes.push(Some(scope));
        }
        if let Some(scope) = &definition.begin_scope {
            if let Some(wrap) = scope.wrap {
                let mut buffer = std::mem::take(&mut self.buffer);
                self.emit_keyword(&buffer, wrap);
                buffer.clear();
                self.buffer = buffer;
            } else if scope.multi {
                self.emit_multi(scope, found)?;
                self.buffer.clear();
            }
        }
        self.stack.push(mode);
        Some(())
    }

    fn end_of_mode(&self, depth: usize, rest: &str) -> Option<Option<usize>> {
        let mode = &self.grammar.modes[self.stack[depth]];
        if let Some(end) = &mode.end {
            if end.captures(rest).ok()??.get(1).is_some() {
                let mut depth = depth;
                while self.grammar.modes[self.stack[depth]].ends_parent && depth > 0 {
                    depth -= 1;
                }
                return Some(Some(depth));
            }
        }
        if mode.ends_with_parent {
            return self.end_of_mode(depth.checked_sub(1)?, rest);
        }
        Some(None)
    }

    fn ignored(&self, mode: &Mode, found: &Found) -> Option<bool> {
        let text = self.text;
        if mode.before_begin && text[..found.start].ends_with('.') {
            return Some(true);
        }
        match mode.on_begin {
            None => Some(false),
            Some(Callback::Shebang) => Some(found.start != 0),
            Some(Callback::Jsx) => {
                let after = &text[found.end..];
                let next = after.chars().next()?;
                if next == '<' || next == ',' {
                    return Some(true);
                }
                let mut ignore = false;
                if next == '>' {
                    let name = &text[found.start + 1..found.end];
                    ignore = !after
                        .match_indices("</")
                        .any(|(at, _)| after[at + 2..].starts_with(name));
                }
                let trimmed = after.trim_start_matches(is_js_space);
                if trimmed.starts_with('=') {
                    return Some(true);
                }
                if trimmed.len() < after.len() {
                    if let Some(rest) = trimmed.strip_prefix("extends") {
                        if rest.starts_with(is_js_space) {
                            return Some(true);
                        }
                    }
                }
                Some(ignore)
            }
        }
    }

    fn begin(&mut self, found: &Found) -> Option<usize> {
        let grammar = self.grammar;
        let top = *self.stack.last()?;
        let mode = grammar.modes[top].rules[found.rule].mode?;
        let definition = &grammar.modes[mode];
        let lexeme = &self.text[found.start..found.end];
        if self.ignored(definition, found)? {
            if grammar.modes[top].regex_index.get() == 0 {
                let first = lexeme.chars().next()?;
                self.buffer.push(first);
                return Some(first.len_utf8());
            }
            self.resume = true;
            return Some(0);
        }
        if definition.skip == Some(true) {
            self.buffer.push_str(lexeme);
        } else {
            if definition.exclude_begin {
                self.buffer.push_str(lexeme);
            }
            self.process_buffer()?;
            if !definition.return_begin && !definition.exclude_begin {
                self.buffer.clear();
                self.buffer.push_str(lexeme);
            }
        }
        self.start_mode(mode, found)?;
        Some(if definition.return_begin {
            0
        } else {
            lexeme.len()
        })
    }

    fn end(&mut self, found: &Found) -> Option<usize> {
        let grammar = self.grammar;
        let lexeme = &self.text[found.start..found.end];
        let Some(end_depth) = self.end_of_mode(self.stack.len() - 1, &self.text[found.start..])?
        else {
            return Some(NO_MATCH);
        };
        let origin = &grammar.modes[*self.stack.last()?];
        let ended = &grammar.modes[self.stack[end_depth]];
        match &origin.end_scope {
            Some(scope) if scope.wrap.is_some() => {
                self.process_buffer()?;
                self.emit_keyword(lexeme, scope.wrap?);
            }
            Some(scope) if scope.multi => {
                self.process_buffer()?;
                self.emit_multi(scope, found)?;
            }
            _ if origin.skip.is_some() => self.buffer.push_str(lexeme),
            _ => {
                if !(origin.return_end || origin.exclude_end) {
                    self.buffer.push_str(lexeme);
                }
                self.process_buffer()?;
                if origin.exclude_end {
                    self.buffer.clear();
                    self.buffer.push_str(lexeme);
                }
            }
        }
        loop {
            if self.top().has_scope {
                self.close_node();
            }
            self.stack.pop();
            if self.stack.len() <= end_depth {
                break;
            }
        }
        if self.stack.is_empty() {
            return None;
        }
        if let Some(starts) = ended.starts {
            self.start_mode(starts, found)?;
        }
        Some(if origin.return_end { 0 } else { lexeme.len() })
    }

    fn process(&mut self, found: &Found, kind: Kind) -> Option<usize> {
        let lexeme = &self.text[found.start..found.end];
        if matches!(self.last, Some((Kind::Begin, index)) if index == found.start)
            && kind == Kind::End
            && lexeme.is_empty()
        {
            let skipped = self.text[found.start..].chars().next()?;
            self.buffer.push(skipped);
            return Some(skipped.len_utf8());
        }
        self.last = Some((kind, found.start));
        match kind {
            Kind::Begin => return self.begin(found),
            Kind::End => {
                let processed = self.end(found)?;
                if processed != NO_MATCH {
                    return Some(processed);
                }
            }
            Kind::Illegal => {
                if lexeme.is_empty() {
                    return None;
                }
            }
        }
        self.buffer.push_str(lexeme);
        Some(lexeme.len())
    }

    fn run(mut self) -> Option<Vec<u32>> {
        let grammar = self.grammar;
        let mut index = 0;
        let mut iterations = 0;
        loop {
            iterations += 1;
            if iterations > 100_000 {
                return None;
            }
            let top = *self.stack.last()?;
            if self.resume {
                self.resume = false;
            } else {
                grammar.modes[top].regex_index.set(0);
            }
            let Some(found) = grammar.exec(top, self.text, index)? else {
                break;
            };
            let kind = grammar.modes[top].rules[found.rule].kind;
            self.buffer.push_str(&self.text[index..found.start]);
            let processed = self.process(&found, kind)?;
            index = found.start + processed;
        }
        self.buffer.push_str(&self.text[index..]);
        self.process_buffer()?;
        let total: u32 = self.runs.iter().map(|(_, length)| length).sum();
        let units = if self.text_is_ascii {
            self.text.len()
        } else {
            utf16_len(self.text)
        };
        if total as usize != units {
            return None;
        }
        let scoped = self.runs.iter().filter(|run| run.0.is_some()).count();
        let mut tokens = Vec::with_capacity(scoped * 3);
        let mut at = 0;
        for (scope, length) in self.runs {
            if let Some(scope) = scope {
                tokens.extend([at, at + length, scope]);
            }
            at += length;
        }
        Some(tokens)
    }
}
