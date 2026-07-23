use ropey::Rope as RustRope;
use std::sync::RwLock;
use unicode_bidi::{bidi_class, BidiClass};

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum TextDirection {
    Ltr,
    Rtl,
    Mixed,
}

#[derive(Clone, Copy, Debug)]
pub struct BiDiSegment {
    pub start: usize,
    pub end: usize,
    pub direction: TextDirection,
}

#[derive(Clone, Copy, Debug)]
pub struct SelectionState {
    pub base_offset: usize,
    pub extent_offset: usize,
}

#[flutter_rust_bridge::frb(opaque)]
pub struct RopeBridge {
    pub(crate) rope: RwLock<RustRope>,
    selection: RwLock<SelectionState>,
}

impl RopeBridge {
    #[flutter_rust_bridge::frb(sync)]
    pub fn create(initial_text: String) -> Self {
        Self {
            rope: RwLock::new(RustRope::from_str(&initial_text)),
            selection: RwLock::new(SelectionState {
                base_offset: 0,
                extent_offset: 0,
            }),
        }
    }

    #[flutter_rust_bridge::frb(sync)]
    pub fn selection(&self) -> SelectionState {
        *self.selection.read().unwrap()
    }

    #[flutter_rust_bridge::frb(sync)]
    pub fn set_selection(&self, base_offset: usize, extent_offset: usize) {
        let len = self.rope.read().unwrap().len_chars();
        let clamped_base = base_offset.min(len);
        let clamped_extent = extent_offset.min(len);
        *self.selection.write().unwrap() = SelectionState {
            base_offset: clamped_base,
            extent_offset: clamped_extent,
        };
    }

    #[flutter_rust_bridge::frb(sync)]
    pub fn replace_range_and_update_selection(
        &self,
        start: usize,
        end: usize,
        replacement: String,
        preserve_old_cursor: bool,
        old_base: usize,
        old_extent: usize,
    ) -> SelectionState {
        let mut rope_write = self.rope.write().unwrap();
        let len = rope_write.len_chars();
        let safe_start = start.min(len);
        let safe_end = end.clamp(safe_start, len);

        if safe_start < safe_end {
            rope_write.remove(safe_start..safe_end);
        }
        if !replacement.is_empty() {
            rope_write.insert(safe_start, &replacement);
        }

        let replacement_chars = replacement.chars().count();
        let new_selection = if preserve_old_cursor {
            let delta = replacement_chars as isize - (safe_end - safe_start) as isize;

            let map_offset = |offset: usize| -> usize {
                if offset <= safe_start {
                    offset
                } else if offset >= safe_end {
                    let mapped = (offset as isize + delta) as isize;
                    mapped.clamp(0, rope_write.len_chars() as isize) as usize
                } else {
                    let relative = offset.saturating_sub(safe_start);
                    let mapped = safe_start + relative.min(replacement_chars);
                    mapped.min(rope_write.len_chars())
                }
            };

            let base = map_offset(old_base);
            let extent = map_offset(old_extent);
            SelectionState {
                base_offset: base,
                extent_offset: extent,
            }
        } else {
            SelectionState {
                base_offset: safe_start + replacement_chars,
                extent_offset: safe_start + replacement_chars,
            }
        };

        *self.selection.write().unwrap() = SelectionState {
            base_offset: new_selection.base_offset.min(rope_write.len_chars()),
            extent_offset: new_selection.extent_offset.min(rope_write.len_chars()),
        };

        new_selection
    }

    #[flutter_rust_bridge::frb(sync)]
    pub fn len_chars(&self) -> usize {
        self.rope.read().unwrap().len_chars()
    }

    #[flutter_rust_bridge::frb(sync)]
    pub fn get_text(&self) -> String {
        self.rope.read().unwrap().to_string()
    }

    #[flutter_rust_bridge::frb(sync)]
    pub fn insert(&self, char_idx: usize, text: String) {
        self.rope.write().unwrap().insert(char_idx, &text);
    }

    #[flutter_rust_bridge::frb(sync)]
    pub fn remove(&self, start: usize, end: usize) {
        self.rope.write().unwrap().remove(start..end);
    }

    #[flutter_rust_bridge::frb(sync)]
    pub fn slice(&self, start: usize, end: usize) -> String {
        let rope = self.rope.read().unwrap();
        let valid_start = start.min(rope.len_chars());
        let valid_end = end.max(valid_start).min(rope.len_chars());
        rope.slice(valid_start..valid_end).to_string()
    }

    #[flutter_rust_bridge::frb(sync)]
    pub fn char_to_line(&self, char_idx: usize) -> usize {
        let rope = self.rope.read().unwrap();
        let valid_idx = char_idx.min(rope.len_chars());
        rope.char_to_line(valid_idx)
    }

    #[flutter_rust_bridge::frb(sync)]
    pub fn line_to_char(&self, line_idx: usize) -> usize {
        let rope = self.rope.read().unwrap();
        let valid_idx = line_idx.min(rope.len_lines().saturating_sub(1));
        rope.line_to_char(valid_idx)
    }

    #[flutter_rust_bridge::frb(sync)]
    pub fn line(&self, line_idx: usize) -> String {
        let rope = self.rope.read().unwrap();
        let valid_idx = line_idx.min(rope.len_lines().saturating_sub(1));
        let mut line_str = rope.line(valid_idx).to_string();
        if line_str.ends_with("\r\n") {
            line_str.truncate(line_str.len() - 2);
        } else if line_str.ends_with('\n') {
            line_str.truncate(line_str.len() - 1);
        }
        line_str
    }
    
    #[flutter_rust_bridge::frb(sync)]
    pub fn len_lines(&self) -> usize {
        self.rope.read().unwrap().len_lines()
    }

    #[flutter_rust_bridge::frb(sync)]
    pub fn char_at(&self, position: usize) -> String {
        let rope = self.rope.read().unwrap();
        if position >= rope.len_chars() {
            return String::new();
        }
        rope.char(position).to_string()
    }
    
    #[flutter_rust_bridge::frb(sync)]
    pub fn copy(&self) -> Self {
        self.deep_clone()
    }

    #[flutter_rust_bridge::frb(sync)]
    pub fn deep_clone(&self) -> Self {
        Self {
            rope: RwLock::new(self.rope.read().unwrap().clone()),
            selection: RwLock::new(*self.selection.read().unwrap()),
        }
    }

    #[flutter_rust_bridge::frb(sync)]
    pub fn cached_lines(&self) -> Vec<String> {
        let rope = self.rope.read().unwrap();
        let total = rope.len_lines();
        drop(rope);
        self.cached_lines_range(0, total)
    }

    #[flutter_rust_bridge::frb(sync)]
    pub fn cached_lines_range(&self, start_line: usize, end_line: usize) -> Vec<String> {
        let rope = self.rope.read().unwrap();
        let total = rope.len_lines();
        let start = start_line.min(total);
        let end = end_line.min(total).max(start);
        let mut lines = Vec::with_capacity(end.saturating_sub(start));
        for line_idx in start..end {
            let mut line_str = rope.line(line_idx).to_string();
            if line_str.ends_with("\r\n") {
                line_str.truncate(line_str.len() - 2);
            } else if line_str.ends_with('\n') {
                line_str.truncate(line_str.len() - 1);
            }
            lines.push(line_str);
        }
        lines
    }
    
    #[flutter_rust_bridge::frb(sync)]
    pub fn primary_direction(&self) -> TextDirection {
        let rope = self.rope.read().unwrap();
        let mut rtl_count = 0;
        let mut ltr_count = 0;
        
        for c in rope.chars() {
            match direction_for_char(c) {
                Some(TextDirection::Rtl) => rtl_count += 1,
                Some(TextDirection::Ltr) => ltr_count += 1,
                _ => {}
            }
        }
        
        if rtl_count == 0 && ltr_count == 0 {
            TextDirection::Ltr
        } else if rtl_count > ltr_count {
            TextDirection::Rtl
        } else {
            TextDirection::Ltr
        }
    }

    #[flutter_rust_bridge::frb(sync)]
    pub fn text_direction(&self) -> TextDirection {
        let rope: std::sync::RwLockReadGuard<'_, RustRope> = self.rope.read().unwrap();
        let mut has_rtl = false;
        let mut has_ltr = false;
        
        for c in rope.chars() {
            match direction_for_char(c) {
                Some(TextDirection::Rtl) => has_rtl = true,
                Some(TextDirection::Ltr) => has_ltr = true,
                _ => {}
            }
            if has_rtl && has_ltr {
                return TextDirection::Mixed;
            }
        }
        
        if !has_rtl && !has_ltr { TextDirection::Ltr }
        else if !has_rtl { TextDirection::Ltr }
        else { TextDirection::Rtl }
    }

    #[flutter_rust_bridge::frb(sync)]
    pub fn get_bidi_segments_in_range(&self, start: usize, end: usize) -> Vec<BiDiSegment> {
        let rope: std::sync::RwLockReadGuard<'_, RustRope> = self.rope.read().unwrap();
        compute_bidi_segments(&rope, start, end)
    }
    
    #[flutter_rust_bridge::frb(sync)]
    pub fn get_bidi_segments_for_line(&self, line_index: usize) -> Vec<BiDiSegment> {
        let rope: std::sync::RwLockReadGuard<'_, RustRope> = self.rope.read().unwrap();
        let valid_idx: usize = line_index.min(rope.len_lines().saturating_sub(1));
        let start: usize = rope.line_to_char(valid_idx);
        let line: ropey::RopeSlice<'_> = rope.line(valid_idx);
        let end: usize = start + line.len_chars();
        compute_bidi_segments(&rope, start, end)
    }

    #[flutter_rust_bridge::frb(sync)]
    pub fn find_line_start(&self, offset: usize) -> usize {
        let line = self.char_to_line(offset);
        self.line_to_char(line)
    }

    #[flutter_rust_bridge::frb(sync)]
    pub fn find_line_end(&self, offset: usize) -> usize {
        let rope = self.rope.read().unwrap();
        let valid_offset = offset.min(rope.len_chars());
        let line = rope.char_to_line(valid_offset);
        let next_line_start = if line + 1 < rope.len_lines() {
            rope.line_to_char(line + 1)
        } else {
            rope.len_chars()
        };
        let line_slice = rope.line(line);
        let line_len = line_slice.len_chars();
        if line_len == 0 {
            return next_line_start;
        }
        let last = line_slice.char(line_len - 1);
        if last == '\n' {
            if line_len >= 2 && line_slice.char(line_len - 2) == '\r' {
                next_line_start.saturating_sub(2)
            } else {
                next_line_start.saturating_sub(1)
            }
        } else {
            next_line_start
        }
    }
}

fn compute_bidi_segments(rope: &RustRope, start: usize, end: usize) -> Vec<BiDiSegment> {
    let end: usize = end.min(rope.len_chars());
    if start >= end {
        return vec![];
    }

    let mut segments = Vec::new();
    let mut current_dir = None;
    let mut segment_start = 0;

    let slice = rope.slice(start..end);

    if slice.len_chars() <= 32 || slice.chars().take(32).all(|c| c.is_ascii()) {
        return vec![BiDiSegment { start, end, direction: TextDirection::Ltr }];
    }

    for (i, c) in slice.chars().enumerate() {
        let char_dir = direction_for_char(c);

        if let Some(cd) = char_dir {
            if current_dir.is_none() {
                current_dir = Some(cd);
                segment_start = i;
            } else if Some(cd) != current_dir {
                segments.push(BiDiSegment {
                    start: start + segment_start,
                    end: start + i,
                    direction: current_dir.unwrap(),
                });
                current_dir = Some(cd);
                segment_start = i;
            }
        }
    }

    if let Some(cd) = current_dir {
        segments.push(BiDiSegment {
            start: start + segment_start,
            end,
            direction: cd,
        });
    }

    segments
}

fn direction_for_char(c: char) -> Option<TextDirection> {
    match bidi_class(c) {
        BidiClass::L => Some(TextDirection::Ltr),
        BidiClass::R | BidiClass::AL | BidiClass::AN => Some(TextDirection::Rtl),
        _ => None,
    }
}
