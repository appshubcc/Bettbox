use crate::editor::{self, highlight, search, Buffer};
use flutter_rust_bridge::frb;

#[derive(Clone, Debug)]
pub struct RustFoldRange {
    pub start_line: i32,
    pub end_line: i32,
}

#[derive(Clone, Debug)]
pub struct GuideBlock {
    pub start_line: i32,
    pub end_line: i32,
    pub indent_level: i32,
    pub leading_spaces: i32,
}

#[derive(Clone, Debug)]
pub struct RopeTextEdit {
    pub start_scalar: u32,
    pub end_scalar: u32,
    pub replacement: String,
}

#[frb(opaque)]
pub struct RopeSnapshot {
    rope: ropey::Rope,
}

impl RopeSnapshot {
    #[frb(sync)]
    pub fn from_text(text: String) -> Self {
        Self {
            rope: Buffer::from_normalized(&text).snapshot(),
        }
    }
}

#[frb(opaque)]
pub struct RopeBridge {
    buffer: Buffer,
}

impl RopeBridge {
    #[frb(sync)]
    pub fn create(initial_text: String) -> Self {
        Self {
            buffer: Buffer::from_normalized(&initial_text),
        }
    }

    pub fn load_file(path: String) -> Result<RopeBridge, String> {
        Buffer::from_file(&path)
            .map(|buffer| Self { buffer })
            .map_err(|err| err.to_string())
    }

    #[frb(sync)]
    pub fn snapshot(
        &self,
        dirty_start: usize,
        dirty_end: usize,
        dirty_text: Option<String>,
    ) -> RopeSnapshot {
        RopeSnapshot {
            rope: self
                .buffer
                .live_rope(dirty_start, dirty_end, dirty_text.as_deref()),
        }
    }

    #[frb(sync)]
    pub fn equals_snapshot(
        &self,
        snapshot: &RopeSnapshot,
        dirty_start: usize,
        dirty_end: usize,
        dirty_text: Option<String>,
    ) -> bool {
        if dirty_text.is_none() {
            let guard = self.buffer.rope();
            return editor::ropes_equal(&guard, &snapshot.rope);
        }
        let live = self
            .buffer
            .live_rope(dirty_start, dirty_end, dirty_text.as_deref());
        editor::ropes_equal(&live, &snapshot.rope)
    }

    #[frb(sync)]
    pub fn diff_text(
        &self,
        dirty_start: usize,
        dirty_end: usize,
        dirty_text: Option<String>,
        new_text: String,
    ) -> Option<RopeTextEdit> {
        if dirty_text.is_none() {
            let guard = self.buffer.rope();
            return editor::diff_slice_and_str(guard.slice(..), &new_text).map(
                |(start_scalar, end_scalar, replacement)| RopeTextEdit {
                    start_scalar,
                    end_scalar,
                    replacement,
                },
            );
        }
        let live = self
            .buffer
            .live_rope(dirty_start, dirty_end, dirty_text.as_deref());
        editor::diff_slice_and_str(live.slice(..), &new_text).map(
            |(start_scalar, end_scalar, replacement)| RopeTextEdit {
                start_scalar,
                end_scalar,
                replacement,
            },
        )
    }

    #[frb(sync)]
    pub fn len_chars(&self) -> usize {
        self.buffer.len_chars()
    }

    #[frb(sync)]
    pub fn get_text(&self) -> String {
        self.buffer.text()
    }

    #[frb(sync)]
    pub fn insert(&self, char_idx: usize, text: String) {
        self.buffer.insert(char_idx, &text)
    }

    #[frb(sync)]
    pub fn remove(&self, start: usize, end: usize) {
        self.buffer.remove(start, end)
    }

    #[frb(sync)]
    pub fn slice(&self, start: usize, end: usize) -> String {
        self.buffer.slice(start, end)
    }

    #[frb(sync)]
    pub fn char_to_line(&self, char_idx: usize) -> usize {
        self.buffer.char_to_line(char_idx)
    }

    #[frb(sync)]
    pub fn line_to_char(&self, line_idx: usize) -> usize {
        self.buffer.line_to_char(line_idx)
    }

    #[frb(sync)]
    pub fn line(&self, line_idx: usize) -> String {
        self.buffer.line(line_idx)
    }

    #[frb(sync)]
    pub fn len_lines(&self) -> usize {
        self.buffer.len_lines()
    }

    #[frb(sync)]
    pub fn cached_lines_range(&self, start_line: usize, end_line: usize) -> Vec<String> {
        self.buffer.lines(start_line, end_line)
    }
}

pub fn folds_compute_all(rope: &RopeBridge, tab_size: usize) -> Vec<RustFoldRange> {
    editor::compute_folds(&rope.buffer.snapshot(), tab_size)
}

#[frb(sync)]
pub fn folds_find_matching_bracket(rope: &RopeBridge, target_offset: usize) -> Option<usize> {
    editor::find_matching_bracket(&rope.buffer.rope(), target_offset)
}

#[frb(sync)]
pub fn guides_compute_viewport(
    rope: &RopeBridge,
    first_visible: usize,
    last_visible: usize,
    tab_size: usize,
) -> Vec<GuideBlock> {
    editor::compute_guides(&rope.buffer.rope(), first_visible, last_visible, tab_size)
}

pub fn words_extract(rope: &RopeBridge) -> Vec<String> {
    editor::extract_words(&rope.buffer.snapshot())
}

fn search_query(
    pattern: String,
    is_regex: bool,
    case_sensitive: bool,
    whole_word: bool,
) -> search::Query {
    search::Query {
        pattern,
        is_regex,
        case_sensitive,
        whole_word,
    }
}

#[frb(sync)]
pub fn search_find(
    text: String,
    pattern: String,
    is_regex: bool,
    case_sensitive: bool,
    whole_word: bool,
) -> Option<Vec<u32>> {
    search::find(
        &text,
        &search_query(pattern, is_regex, case_sensitive, whole_word),
    )
}

#[frb(sync)]
pub fn search_find_rope(
    rope: &RopeBridge,
    start_char: usize,
    end_char: usize,
    dirty_start: usize,
    dirty_end: usize,
    dirty_text: Option<String>,
    pattern: String,
    is_regex: bool,
    case_sensitive: bool,
    whole_word: bool,
) -> Option<Vec<u32>> {
    let query = search_query(pattern, is_regex, case_sensitive, whole_word);
    if dirty_text.is_none() {
        let guard = rope.buffer.rope();
        let len = guard.len_chars();
        let start = start_char.min(len);
        let end = end_char.max(start).min(len);
        return search::find_in_slice(guard.slice(start..end), &query);
    }
    let live = rope
        .buffer
        .live_rope(dirty_start, dirty_end, dirty_text.as_deref());
    let len = live.len_chars();
    let start = start_char.min(len);
    let end = end_char.max(start).min(len);
    search::find_in_slice(live.slice(start..end), &query)
}

#[frb(sync)]
pub fn search_replace_all(
    text: String,
    pattern: String,
    is_regex: bool,
    case_sensitive: bool,
    whole_word: bool,
    replacement: String,
) -> Option<String> {
    search::replace_all(
        &text,
        &search_query(pattern, is_regex, case_sensitive, whole_word),
        &replacement,
    )
}

#[frb(sync)]
pub fn search_replace_all_rope(
    rope: &RopeBridge,
    dirty_start: usize,
    dirty_end: usize,
    dirty_text: Option<String>,
    pattern: String,
    is_regex: bool,
    case_sensitive: bool,
    whole_word: bool,
    replacement: String,
) -> Option<RopeTextEdit> {
    let query = search_query(pattern, is_regex, case_sensitive, whole_word);
    let map_edit = |edit: search::ReplaceAllEdit| RopeTextEdit {
        start_scalar: edit.start_scalar,
        end_scalar: edit.end_scalar,
        replacement: edit.replacement,
    };
    if dirty_text.is_none() {
        let guard = rope.buffer.rope();
        return search::replace_all_in_rope(&guard, &query, &replacement).map(map_edit);
    }
    let live = rope
        .buffer
        .live_rope(dirty_start, dirty_end, dirty_text.as_deref());
    search::replace_all_in_rope(&live, &query, &replacement).map(map_edit)
}

/// `[start, end, scope, ...]` in UTF-16 code units, for one line of YAML.
#[frb(sync)]
pub fn highlight_yaml_line(text: String) -> Vec<u32> {
    highlight::highlight_yaml(&text)
}

/// As [highlight_yaml_line] with scopes numbered as [highlight_javascript_scopes]
/// names them; `None` for a line the caller has to highlight itself.
#[frb(sync)]
pub fn highlight_javascript_line(text: String) -> Option<Vec<u32>> {
    highlight::highlight_javascript(&text)
}

#[frb(sync)]
pub fn highlight_javascript_scopes() -> Vec<String> {
    highlight::javascript_scopes()
}
