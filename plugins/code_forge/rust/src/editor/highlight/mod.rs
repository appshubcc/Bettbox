mod engine;
mod yaml;

pub use yaml::highlight as highlight_yaml;

thread_local! {
    static JAVASCRIPT: Option<engine::Grammar> =
        engine::Grammar::parse(include_str!("javascript.json"));
}

/// `None` where the line has to be left to re_highlight.
pub fn highlight_javascript(text: &str) -> Option<Vec<u32>> {
    JAVASCRIPT.with(|grammar| grammar.as_ref()?.highlight(text))
}

pub fn javascript_scopes() -> Vec<String> {
    JAVASCRIPT.with(|grammar| {
        grammar
            .as_ref()
            .map_or_else(Vec::new, |grammar| grammar.scopes().to_vec())
    })
}

pub const ATTR: u32 = 0;
pub const META: u32 = 1;
pub const STRING: u32 = 2;
pub const TYPE: u32 = 3;
pub const BULLET: u32 = 4;
pub const COMMENT: u32 = 5;
pub const DOCTAG: u32 = 6;
pub const LITERAL: u32 = 7;
pub const NUMBER: u32 = 8;
pub const TEMPLATE_VARIABLE: u32 = 9;

/// One line as chars, with where each starts in bytes and in UTF-16 units.
pub(super) struct Line {
    pub chars: Vec<char>,
    utf16: Vec<u32>,
    tokens: Vec<u32>,
}

impl Line {
    pub fn new(text: &str) -> Self {
        let mut chars = Vec::with_capacity(text.len());
        let mut utf16 = Vec::with_capacity(text.len() + 1);
        let mut units = 0u32;
        for ch in text.chars() {
            chars.push(ch);
            utf16.push(units);
            units += ch.len_utf16() as u32;
        }
        utf16.push(units);
        Self {
            chars,
            utf16,
            tokens: Vec::new(),
        }
    }

    pub fn len(&self) -> usize {
        self.chars.len()
    }

    pub fn at(&self, index: usize) -> Option<char> {
        self.chars.get(index).copied()
    }

    /// Whether `$` matches here, as in a JavaScript multiline pattern.
    pub fn ends_at(&self, index: usize) -> bool {
        self.at(index).map_or(true, is_line_terminator)
    }

    pub fn starts_at(&self, index: usize) -> bool {
        index == 0 || is_line_terminator(self.chars[index - 1])
    }

    pub fn emit(&mut self, scope: u32, start: usize, end: usize) {
        if end > start {
            self.tokens
                .extend([self.utf16[start], self.utf16[end], scope]);
        }
    }

    pub fn tokens_len(&self) -> usize {
        self.tokens.len()
    }

    /// Emits a token ahead of those emitted since [tokens_len] was `before`.
    pub fn insert(&mut self, before: usize, scope: u32, start: usize, end: usize) {
        if end > start {
            self.tokens
                .splice(before..before, [self.utf16[start], self.utf16[end], scope]);
        }
    }

    pub fn finish(self) -> Vec<u32> {
        self.tokens
    }
}

pub(super) fn is_word(ch: char) -> bool {
    ch.is_ascii_alphanumeric() || ch == '_'
}

pub(super) fn is_line_terminator(ch: char) -> bool {
    matches!(ch, '\n' | '\r' | '\u{2028}' | '\u{2029}')
}

/// What `\s` matches in a JavaScript pattern.
pub(super) fn is_space(ch: char) -> bool {
    matches!(
        ch,
        '\t' | '\n' | '\u{b}' | '\u{c}' | '\r' | ' ' | '\u{a0}' | '\u{1680}' | '\u{2000}'
            ..='\u{200a}'
                | '\u{2028}'
                | '\u{2029}'
                | '\u{202f}'
                | '\u{205f}'
                | '\u{3000}'
                | '\u{feff}'
    )
}
