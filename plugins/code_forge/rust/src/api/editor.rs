use flutter_rust_bridge::frb;
use ropey::Rope as RustRope;
use zed_sum_tree::{Bias, Dimension, Dimensions, Item, SumTree, Summary};
use crate::api::rope::RopeBridge;
use std::collections::HashSet;
use std::mem;

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}

#[derive(Clone, Debug)]
pub struct LineBlock {
    pub len_chars: usize,
    pub height: f32,
    pub is_folded: bool,
}

#[derive(Clone, Debug, Default, PartialEq)]
pub struct LineSummary {
    pub len_chars: usize,
    pub height: f32,
    pub lines: usize,
}

impl Summary for LineSummary {
    type Context<'a> = ();
    
    fn zero(_cx: ()) -> Self {
        Self::default()
    }
    
    fn add_summary(&mut self, other: &Self, _: ()) {
        self.len_chars += other.len_chars;
        self.height += other.height;
        self.lines += other.lines;
    }
}

impl Item for LineBlock {
    type Summary = LineSummary;
    fn summary(&self, _: ()) -> Self::Summary {
        LineSummary {
            len_chars: self.len_chars,
            height: if self.is_folded { 0.0 } else { self.height },
            lines: 1,
        }
    }
}

#[derive(Clone, Copy, Debug, Default, PartialEq, Eq, PartialOrd, Ord)]
pub struct LineCount(pub usize);

#[derive(Clone, Copy, Debug, Default, PartialEq, Eq, PartialOrd, Ord)]
pub struct CharOffset(pub usize);

#[derive(Clone, Copy, Debug, Default, PartialEq)]
pub struct PixelHeight(pub f32);

impl Eq for PixelHeight {}

impl PartialOrd for PixelHeight {
    fn partial_cmp(&self, other: &Self) -> Option<std::cmp::Ordering> {
        Some(self.cmp(other))
    }
}

impl Ord for PixelHeight {
    fn cmp(&self, other: &Self) -> std::cmp::Ordering {
        self.0.total_cmp(&other.0)
    }
}

impl<'a> Dimension<'a, LineSummary> for LineCount {
    fn zero(_: ()) -> Self {
        Self(0)
    }

    fn add_summary(&mut self, summary: &'a LineSummary, _: ()) {
        self.0 += summary.lines;
    }
}

impl<'a> Dimension<'a, LineSummary> for CharOffset {
    fn zero(_: ()) -> Self {
        Self(0)
    }

    fn add_summary(&mut self, summary: &'a LineSummary, _: ()) {
        self.0 += summary.len_chars;
    }
}

impl<'a> Dimension<'a, LineSummary> for PixelHeight {
    fn zero(_: ()) -> Self {
        Self(0.0)
    }

    fn add_summary(&mut self, summary: &'a LineSummary, _: ()) {
        self.0 += summary.height;
    }
}

#[frb(opaque)]
pub struct LayoutMap {
    tree: SumTree<LineBlock>,
}

impl LayoutMap {
    #[frb(sync)]
    pub fn new() -> Self {
        Self {
            tree: SumTree::new(()),
        }
    }

    #[frb(sync)]
    pub fn push_line(&mut self, len_chars: usize, height: f32, is_folded: bool) {
        self.tree.push(
            LineBlock {
                len_chars,
                height,
                is_folded,
            },
            (),
        );
    }

    #[frb(sync)]
    pub fn insert_line(&mut self, line_idx: usize, len_chars: usize, height: f32, is_folded: bool) {
        if line_idx >= self.len_lines() {
            self.push_line(len_chars, height, is_folded);
            return;
        }
        let new_tree = {
            let mut cursor = self.tree.cursor::<LineCount>(());
            let mut new_tree = cursor.slice(&LineCount(line_idx), Bias::Left);
            new_tree.push(
                LineBlock {
                    len_chars,
                    height,
                    is_folded,
                },
                (),
            );
            new_tree.append(cursor.suffix(), ());
            new_tree
        };
        self.tree = new_tree;
    }

    #[frb(sync)]
    pub fn remove_line(&mut self, line_idx: usize) {
        if line_idx >= self.len_lines() {
            return;
        }
        let new_tree: SumTree<LineBlock> = {
            let mut cursor: zed_sum_tree::Cursor<'_, '_, LineBlock, LineCount> = self.tree.cursor::<LineCount>(());
            let mut new_tree: SumTree<LineBlock> = cursor.slice(&LineCount(line_idx), Bias::Left);
            cursor.next();
            new_tree.append(cursor.suffix(), ());
            new_tree
        };
        self.tree = new_tree;
    }

    #[frb(sync)]
    pub fn clear(&mut self) {
        self.tree = SumTree::new(());
    }

    #[frb(sync)]
    pub fn total_height(&self) -> f64 {
        self.tree.summary().height as f64
    }

    #[frb(sync)]
    pub fn len_lines(&self) -> usize {
        self.tree.summary().lines
    }

    #[frb(sync)]
    pub fn update_line(&mut self, line_idx: usize, len_chars: usize, height: f32, is_folded: bool) {
        if line_idx >= self.len_lines() {
            return;
        }
        let new_tree: SumTree<LineBlock> = {
            let mut cursor: zed_sum_tree::Cursor<'_, '_, LineBlock, LineCount> = self.tree.cursor::<LineCount>(());
            let mut new_tree: SumTree<LineBlock> = cursor.slice(&LineCount(line_idx), Bias::Left);
            cursor.next();
            new_tree.push(
                LineBlock {
                    len_chars,
                    height,
                    is_folded,
                },
                (),
            );
            new_tree.append(cursor.suffix(), ());
            new_tree
        };
        self.tree = new_tree;
    }

    #[frb(sync)]
    pub fn visual_line_from_char_offset(&self, char_offset: usize) -> i32 {
        if self.tree.summary().lines == 0 {
            return 0;
        }

        let mut cursor = self.tree.cursor::<Dimensions<CharOffset, LineCount>>(());
        cursor.seek(&CharOffset(char_offset), Bias::Left);
        cursor.start().1.0 as i32
    }

    #[frb(sync)]
    pub fn visible_range_by_height(&self, view_top: f64, view_bottom: f64) -> VisibleLineRange {
        if self.tree.summary().lines == 0 {
            return VisibleLineRange {
                first_line: 0,
                last_line: 0,
                first_line_y: 0.0,
            };
        }

        let mut start_cursor = self.tree.cursor::<Dimensions<PixelHeight, LineCount>>(());
        start_cursor.seek(&PixelHeight(view_top.max(0.0) as f32), Bias::Left);
        let first_line = start_cursor.start().1.0 as i32;
        let first_line_y = start_cursor.start().0.0 as f64;

        let mut end_cursor = self.tree.cursor::<Dimensions<PixelHeight, LineCount>>(());
        end_cursor.seek(&PixelHeight(view_bottom.max(view_top) as f32), Bias::Right);
        let mut last_line = end_cursor.start().1.0 as i32;
        let max_line = self.tree.summary().lines.saturating_sub(1) as i32;
        if last_line > max_line {
            last_line = max_line;
        }
        if last_line < first_line {
            last_line = first_line;
        }

        VisibleLineRange {
            first_line,
            last_line,
            first_line_y,
        }
    }

    #[frb(sync)]
    pub fn build_viewport_frame(
        &self,
        view_top: f64,
        view_bottom: f64,
        fallback_line_height: f64,
    ) -> ViewportFrame {
        if self.tree.summary().lines == 0 {
            return ViewportFrame {
                first_line: 0,
                last_line: 0,
                first_line_y: 0.0,
                lines: Vec::new(),
            };
        }

        let visible = self.visible_range_by_height(view_top, view_bottom);
        let mut cursor = self.tree.cursor::<Dimensions<PixelHeight, LineCount>>(());
        cursor.seek(&PixelHeight(view_top.max(0.0) as f32), Bias::Left);

        let mut lines = Vec::new();
        let bottom = view_bottom.max(view_top) as f32;

        while let Some(item) = cursor.item() {
            let line_top = cursor.start().0.0;
            if line_top > bottom {
                break;
            }

            let line_height = if item.is_folded {
                0.0
            } else if item.height > 0.0 {
                item.height
            } else {
                fallback_line_height.max(1.0) as f32
            };

            lines.push(LineSummary {
                len_chars: item.len_chars,
                height: line_height,
                lines: 1,
            });

            cursor.next();
        }

        let computed_last = if lines.is_empty() {
            visible.first_line
        } else {
            visible.first_line + lines.len() as i32 - 1
        };

        ViewportFrame {
            first_line: visible.first_line,
            last_line: computed_last.max(visible.first_line),
            first_line_y: visible.first_line_y,
            lines,
        }
    }
}

pub struct RustFoldRange {
    pub start_line: i32,
    pub end_line: i32,
}

pub fn folds_compute_all(rope: &RopeBridge) -> Vec<RustFoldRange> {
    let mut folds = Vec::new();
    let mut stack: Vec<(char, i32)> = Vec::new();
    let mut line_idx: i32 = 0;

    let rope = rope.rope.read().unwrap();
    for ch in rope.chars() {
        if ch == '\n' {
            line_idx += 1;
        }
        if ch == '{' || ch == '[' || ch == '(' {
            stack.push((ch, line_idx));
        } else if ch == '}' || ch == ']' || ch == ')' {
            if let Some((open_ch, start_line)) = stack.pop() {
                let matches = match (open_ch, ch) {
                    ('{', '}') => true,
                    ('[', ']') => true,
                    ('(', ')') => true,
                    _ => false,
                };
                if matches && start_line < line_idx {
                    folds.push(RustFoldRange {
                        start_line,
                        end_line: line_idx,
                    });
                }
            }
        }
    }
    folds
}

#[frb(sync)]
pub fn folds_find_matching_bracket(rope: &RopeBridge, target_offset: i32) -> i64 {
    if target_offset < 0 {
        return -1;
    }
    let rope = rope.rope.read().unwrap();
    find_matching_bracket_in_rope(&rope, target_offset as usize)
        .map(|idx| idx as i64)
        .unwrap_or(-1)
}

#[derive(Clone, Debug)]
pub struct GuideBlock {
    pub start_line: i32,
    pub end_line: i32,
    pub indent_level: i32,
    pub leading_spaces: i32,
}

#[derive(Clone, Debug)]
pub struct VisibleLineRange {
    pub first_line: i32,
    pub last_line: i32,
    pub first_line_y: f64,
}

#[derive(Clone, Debug)]
pub struct ViewportFrame {
    pub first_line: i32,
    pub last_line: i32,
    pub first_line_y: f64,
    pub lines: Vec<LineSummary>,
}

#[frb(sync)]
pub fn visible_line_range_unwrapped(
    total_lines: i32,
    view_top: f64,
    view_bottom: f64,
    line_height: f64,
) -> VisibleLineRange {
    if total_lines <= 0 {
        return VisibleLineRange {
            first_line: 0,
            last_line: 0,
            first_line_y: 0.0,
        };
    }

    let safe_line_height = if line_height > 0.0 { line_height } else { 1.0 };
    let max_line = total_lines - 1;

    let first = (view_top / safe_line_height).floor() as i32;
    let last = (view_bottom / safe_line_height).ceil() as i32;

    let first_line = first.clamp(0, max_line);
    let last_line = last.clamp(0, max_line);

    VisibleLineRange {
        first_line,
        last_line,
        first_line_y: first_line as f64 * safe_line_height,
    }
}

#[frb(sync)]
pub fn build_viewport_frame(
    rope: &RopeBridge,
    view_top: f64,
    view_bottom: f64,
    line_height: f64,
) -> ViewportFrame {
    let total_lines = rope.len_lines() as i32;
    if total_lines <= 0 {
        return ViewportFrame {
            first_line: 0,
            last_line: 0,
            first_line_y: 0.0,
            lines: Vec::new(),
        };
    }

    let safe_line_height = if line_height > 0.0 { line_height } else { 1.0 };
    let max_line = total_lines - 1;

    let first = (view_top / safe_line_height).floor() as i32;
    let last = (view_bottom / safe_line_height).ceil() as i32;

    let first_line = first.clamp(0, max_line);
    let last_line = last.clamp(0, max_line);

    let mut lines: Vec<LineSummary> = Vec::new();
    let rope_lock = rope.rope.read().unwrap();
    for idx in first_line..=last_line {
        let li = idx as usize;
        if li < rope_lock.len_lines() {
            let line_slice = rope_lock.line(li);
            let len_chars = line_slice.len_chars();
            lines.push(LineSummary {
                len_chars,
                height: safe_line_height as f32,
                lines: 1,
            });
        } else {
            lines.push(LineSummary {
                len_chars: 0,
                height: safe_line_height as f32,
                lines: 1,
            });
        }
    }

    ViewportFrame {
        first_line,
        last_line,
        first_line_y: first_line as f64 * safe_line_height,
        lines,
    }
}

#[frb(sync)]
pub fn guides_compute_viewport(
    _rope: &RopeBridge,
    _first_visible: usize,
    _last_visible: usize,
    _tab_size: usize,
) -> Vec<GuideBlock> {
    let scan_back_limit: usize = 500;

    let rope_lock = _rope.rope.read().unwrap();
    let total_lines = rope_lock.len_lines();

    if total_lines == 0 {
        return Vec::new();
    }

    let first = _first_visible.min(total_lines.saturating_sub(1));
    let last = _last_visible.min(total_lines.saturating_sub(1));
    let scan_start = if first > scan_back_limit { first - scan_back_limit } else { 0 };

    let mut blocks: Vec<GuideBlock> = Vec::new();

    for line_idx in scan_start..=last {
        let line_slice = rope_lock.line(line_idx);
        let mut line_len = line_slice.len_chars();

        if line_len >= 2 {
            if line_slice.char(line_len - 1) == '\n' && line_slice.char(line_len - 2) == '\r' {
                line_len = line_len.saturating_sub(2);
            }
        }
        if line_len >= 1 {
            if line_slice.char(line_len - 1) == '\n' {
                line_len = line_len.saturating_sub(1);
            }
        }

        while line_len > 0 && line_slice.char(line_len - 1).is_whitespace() {
            line_len -= 1;
        }

        if line_len == 0 {
            continue;
        }

        let last_char = line_slice.char(line_len - 1);
        let opening_tag_name = extract_opening_tag_name(&line_slice.slice(..line_len).to_string());
        let ends_with_bracket = matches!(last_char, '{' | '(' | '[' | ':');
        if !ends_with_bracket && opening_tag_name.is_none() {
            continue;
        }

        let mut leading_cols: usize = 0;
        for i in 0..line_len {
            let c = line_slice.char(i);
            if c == ' ' {
                leading_cols += 1;
            } else if c == '\t' {
                        leading_cols += if _tab_size > 0 {
                            let remainder = leading_cols % _tab_size;
                            if remainder == 0 {
                                _tab_size
                            } else {
                                _tab_size - remainder
                            }
                        } else {
                            1
                        };
            } else {
                break;
            }
        }

        let indent_level = if _tab_size > 0 { leading_cols / _tab_size } else { 0 };

        let mut end_line: usize = line_idx + 1;

        if matches!(last_char, '{' | '(' | '[') {
            let line_start_char = rope_lock.line_to_char(line_idx);
            let trimmed_len = line_len;
            if trimmed_len > 0 {
                let bracket_pos = line_start_char + trimmed_len - 1;
                if let Some(match_pos) = find_matching_bracket_in_rope(&rope_lock, bracket_pos)
                {
                    let matched_line = rope_lock.char_to_line(match_pos);
                    end_line = matched_line + 1;
                }
            }
        } else if let Some(tag_name) = opening_tag_name {
            if let Some(match_line) = find_matching_closing_tag_line(&rope_lock, line_idx, &tag_name) {
                end_line = match_line + 1;
            }
        }

        if end_line <= line_idx + 1 {
            let mut scan = line_idx + 1;
            let mut last_valid = line_idx;
            while scan < total_lines {
                let line_slice = rope_lock.line(scan);
                let mut nl_len = line_slice.len_chars();
                if nl_len >= 2 {
                    if line_slice.char(nl_len - 1) == '\n' && line_slice.char(nl_len - 2) == '\r' {
                        nl_len = nl_len.saturating_sub(2);
                    }
                }
                if nl_len >= 1 {
                    if line_slice.char(nl_len - 1) == '\n' {
                        nl_len = nl_len.saturating_sub(1);
                    }
                }
                let mut is_empty = true;
                for i in 0..nl_len {
                    if !line_slice.char(i).is_whitespace() {
                        is_empty = false;
                        break;
                    }
                }
                if is_empty {
                    scan += 1;
                    continue;
                }
                let mut next_leading: usize = 0;
                for i in 0..nl_len {
                    let c = line_slice.char(i);
                    if c == ' ' {
                        next_leading += 1;
                    } else if c == '\t' {
                        next_leading += if _tab_size > 0 {
                            let remainder = next_leading % _tab_size;
                            if remainder == 0 {
                                _tab_size
                            } else {
                                _tab_size - remainder
                            }
                        } else {
                            1
                        };
                    } else {
                        break;
                    }
                }
                if next_leading <= leading_cols {
                    break;
                }
                last_valid = scan;
                scan += 1;
            }
            end_line = last_valid + 1;
        }

        if end_line <= line_idx + 1 {
            continue;
        }

        let mut would_pass = false;
        if end_line > line_idx + 1 {
            for check in (line_idx + 1)..(end_line.saturating_sub(1)) {
                let cl_slice = rope_lock.line(check);
                let mut cl_len = cl_slice.len_chars();
                if cl_len >= 2 {
                    if cl_slice.char(cl_len - 1) == '\n' && cl_slice.char(cl_len - 2) == '\r' {
                        cl_len = cl_len.saturating_sub(2);
                    }
                }
                if cl_len >= 1 {
                    if cl_slice.char(cl_len - 1) == '\n' {
                        cl_len = cl_len.saturating_sub(1);
                    }
                }
                let mut is_empty = true;
                for i in 0..cl_len {
                    if !cl_slice.char(i).is_whitespace() {
                        is_empty = false;
                        break;
                    }
                }
                if is_empty {
                    continue;
                }
                let mut check_leading: usize = 0;
                for i in 0..cl_len {
                    let c = cl_slice.char(i);
                    if c == ' ' {
                        check_leading += 1;
                    } else if c == '\t' {
                        check_leading += if _tab_size > 0 {
                            let remainder = check_leading % _tab_size;
                            if remainder == 0 {
                                _tab_size
                            } else {
                                _tab_size - remainder
                            }
                        } else {
                            1
                        };
                    } else {
                        break;
                    }
                }
                if check_leading <= leading_cols {
                    would_pass = true;
                    break;
                }
            }
        }

        if would_pass {
            continue;
        }

        blocks.push(GuideBlock {
            start_line: line_idx as i32,
            end_line: end_line as i32,
            indent_level: indent_level as i32,
            leading_spaces: leading_cols as i32,
        });
    }

    blocks
}

fn find_matching_bracket_in_rope(rope: &RustRope, target_offset: usize) -> Option<usize> {
    let len = rope.len_chars();
    if target_offset >= len {
        return None;
    }

    let start_ch: char = rope.char(target_offset);

    let (matcher, search_forward) = match start_ch {
        '{' => ('}', true),
        '[' => (']', true),
        '(' => (')', true),
        '}' => ('{', false),
        ']' => ('[', false),
        ')' => ('(', false),
        _ => return None,
    };

    let mut depth = 1;

    if search_forward {
        for (i, ch) in rope.chars_at(target_offset + 1).enumerate() {
            let idx = target_offset + 1 + i;
            if idx >= len {
                break;
            }
            if ch == start_ch {
                depth += 1;
            } else if ch == matcher {
                depth -= 1;
                if depth == 0 {
                    return Some(idx);
                }
            }
        }
    } else {
        if target_offset == 0 {
            return None;
        }
        let mut idx = target_offset;
        while idx > 0 {
            idx -= 1;
            let ch = rope.char(idx);
            if ch == start_ch {
                depth += 1;
            } else if ch == matcher {
                depth -= 1;
                if depth == 0 {
                    return Some(idx);
                }
            }
        }
    }

    None
}

fn extract_opening_tag_name(line: &str) -> Option<String> {
    let trimmed = line.trim_end();
    if !trimmed.ends_with('>') || trimmed.ends_with("/>") || trimmed.ends_with("-->") {
        return None;
    }

    let start = trimmed.find('<')?;
    let mut chars = trimmed[start + 1..].chars();
    let first = chars.next()?;
    if !first.is_ascii_alphabetic() {
        return None;
    }

    let mut name = String::new();
    name.push(first);
    for ch in chars {
        if ch.is_ascii_alphanumeric() || matches!(ch, ':' | '_' | '-') {
            name.push(ch);
        } else {
            break;
        }
    }

    if name.is_empty() { None } else { Some(name) }
}

fn find_matching_closing_tag_line(
    rope: &RustRope,
    start_line: usize,
    tag_name: &str,
) -> Option<usize> {
    let mut depth = 1usize;
    let total_lines = rope.len_lines();

    for line_idx in (start_line + 1)..total_lines {
        let mut line_str = rope.line(line_idx).to_string();
        if line_str.ends_with("\r\n") {
            line_str.truncate(line_str.len() - 2);
        } else if line_str.ends_with('\n') {
            line_str.truncate(line_str.len() - 1);
        }

        let trimmed = line_str.trim();
        if trimmed.is_empty() {
            continue;
        }

        if contains_same_tag_opening(trimmed, tag_name) {
            depth += 1;
        }

        if contains_same_tag_closing(trimmed, tag_name) {
            depth = depth.saturating_sub(1);
            if depth == 0 {
                return Some(line_idx);
            }
        }
    }

    None
}

fn contains_same_tag_opening(line: &str, tag_name: &str) -> bool {
    let opening = format!("<{}", tag_name);
    line.contains(&opening) && !line.contains(&format!("</{}", tag_name)) && !line.ends_with("/>")
}

fn contains_same_tag_closing(line: &str, tag_name: &str) -> bool {
    line.contains(&format!("</{}", tag_name))
}

pub fn words_extract(rope: &RopeBridge) -> Vec<String> {
    let mut words = HashSet::new();
    let mut current_word = String::new();

    let rope = rope.rope.read().unwrap();
    for ch in rope.chars() {
        if ch.is_alphanumeric() || ch == '_' {
            current_word.push(ch);
        } else {
            if !current_word.is_empty() {
                if words.len() < 5_000 {
                    words.insert(mem::take(&mut current_word));
                } else {
                    current_word.clear();
                }
            }
        }
    }
    if !current_word.is_empty() {
        if words.len() < 5_000 {
            words.insert(current_word);
        }
    }
    
    words.into_iter().collect()
}
