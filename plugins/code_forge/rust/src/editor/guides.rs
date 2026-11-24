use crate::api::editor::GuideBlock;
use ropey::{Rope, RopeSlice};

const SCAN_BACK_LIMIT: usize = 500;

#[derive(Clone, Copy, Default)]
struct LineMeta {
    is_blank: bool,
    leading_cols: usize,
    last_char: u8,
    bracket_pos: usize,
}

#[inline(always)]
fn parse_str(s: &str, line_char_offset: usize, tab_size: usize) -> LineMeta {
    let bytes = s.as_bytes();
    let len = bytes.len();
    let mut i = 0;
    let mut leading_cols = 0;
    if tab_size > 0 {
        while i < len {
            match bytes[i] {
                b' ' => leading_cols += 1,
                b'\t' => leading_cols += tab_size - leading_cols % tab_size,
                _ => break,
            }
            i += 1;
        }
    } else {
        while i < len {
            match bytes[i] {
                b' ' | b'\t' => leading_cols += 1,
                _ => break,
            }
            i += 1;
        }
    }
    let mut end = len;
    while end > 0 && matches!(bytes[end - 1], b' ' | b'\t'..=b'\r') {
        end -= 1;
    }
    if end > i && bytes[end - 1] >= 128 {
        end = s[..end].trim_end_matches(char::is_whitespace).len();
    }
    if end <= i {
        return LineMeta {
            is_blank: true,
            leading_cols: 0,
            last_char: 0,
            bracket_pos: 0,
        };
    }
    let last_b = bytes[end - 1];
    let (last_char, bracket_pos) = if matches!(last_b, b'{' | b'(' | b'[' | b':') {
        let char_offset = if s.is_ascii() {
            line_char_offset + end - 1
        } else {
            line_char_offset + s[..end - 1].chars().count()
        };
        (last_b, char_offset)
    } else {
        (0, 0)
    };
    LineMeta {
        is_blank: false,
        leading_cols,
        last_char,
        bracket_pos,
    }
}

#[inline(always)]
fn parse_line(line: RopeSlice, line_char_offset: usize, tab_size: usize) -> LineMeta {
    if let Some(s) = line.as_str() {
        parse_str(s, line_char_offset, tab_size)
    } else {
        let s = line.to_string();
        parse_str(&s, line_char_offset, tab_size)
    }
}

pub fn compute_viewport(
    rope: &Rope,
    first_visible: usize,
    last_visible: usize,
    tab_size: usize,
) -> Vec<GuideBlock> {
    let total_lines = rope.len_lines();
    if total_lines == 0 {
        return Vec::new();
    }

    let first = first_visible.min(total_lines.saturating_sub(1));
    let last = last_visible.min(total_lines.saturating_sub(1));
    let scan_start = first.saturating_sub(SCAN_BACK_LIMIT);
    let horizon = (last + 2).min(total_lines);
    if scan_start >= horizon {
        return Vec::new();
    }

    let count = horizon - scan_start;
    let mut metas: Vec<LineMeta> = Vec::with_capacity(count);
    let mut char_offset = rope.line_to_char(scan_start);

    for line in rope.lines_at(scan_start).take(count) {
        let meta = parse_line(line, char_offset, tab_size);
        char_offset += line.len_chars();
        metas.push(meta);
    }

    let limit_char = rope.line_to_char(horizon);
    let mut blocks: Vec<GuideBlock> = Vec::new();

    for line_idx in scan_start..=last {
        let meta = metas[line_idx - scan_start];
        if meta.is_blank || meta.last_char == 0 {
            continue;
        }

        let leading_cols = meta.leading_cols;
        let indent_level = leading_cols.checked_div(tab_size).unwrap_or(0);
        let mut end_line: usize = line_idx + 1;

        if matches!(meta.last_char, b'{' | b'(' | b'[') {
            let (open, close) = match meta.last_char {
                b'{' => ('{', '}'),
                b'[' => ('[', ']'),
                _ => ('(', ')'),
            };
            if let Some(match_pos) =
                find_matching_bracket_forward(rope, meta.bracket_pos, open, close, limit_char)
            {
                end_line = rope.char_to_line(match_pos) + 1;
            }
        }

        if end_line <= line_idx + 1 {
            let mut scan = line_idx + 1;
            let mut last_valid = line_idx;
            while scan < horizon {
                let m = metas[scan - scan_start];
                if m.is_blank {
                    scan += 1;
                    continue;
                }
                if m.leading_cols <= leading_cols {
                    break;
                }
                last_valid = scan;
                scan += 1;
            }
            end_line = if scan == horizon && horizon < total_lines {
                horizon
            } else {
                last_valid + 1
            };
        }

        if end_line <= line_idx + 1 {
            continue;
        }

        let would_pass = ((line_idx + 1)..(end_line.saturating_sub(1).min(horizon))).any(|check| {
            let m = metas[check - scan_start];
            !m.is_blank && m.leading_cols <= leading_cols
        });

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

#[inline(always)]
fn find_matching_bracket_forward(
    rope: &Rope,
    open_offset: usize,
    open: char,
    close: char,
    limit_char: usize,
) -> Option<usize> {
    let mut depth = 1usize;
    for (i, ch) in rope.chars_at(open_offset + 1).enumerate() {
        let idx = open_offset + 1 + i;
        if idx >= limit_char {
            break;
        }
        if ch == open {
            depth += 1;
        } else if ch == close {
            depth -= 1;
            if depth == 0 {
                return Some(idx);
            }
        }
    }
    None
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_compute_viewport_yaml_and_brackets() {
        let yaml = "proxies:\n  - name: hk01\n    type: vmess\n    server: hk01.example.com\n    ws-opts: {\n      headers: {\n        Host: [example.com]\n      }\n    }\n\n  - name: jp02\n    type: ss\n";
        let rope = Rope::from_str(yaml);
        let blocks = compute_viewport(&rope, 0, 15, 2);
        assert_eq!(blocks.len(), 3);
        assert_eq!((blocks[0].start_line, blocks[0].end_line), (0, 12));
        assert_eq!((blocks[1].start_line, blocks[1].end_line), (4, 9));
        assert_eq!((blocks[2].start_line, blocks[2].end_line), (5, 8));
    }

    #[test]
    fn test_compute_viewport_unicode_spaces() {
        let spans = |text: &str| -> Vec<(i32, i32)> {
            compute_viewport(&Rope::from_str(text), 0, 10, 2)
                .into_iter()
                .map(|block| (block.start_line, block.end_line))
                .collect()
        };
        assert_eq!(spans("x:\u{3000}\n  b\n"), [(0, 2)]);
        assert_eq!(spans("{\u{3000}\n  b\n}\n"), [(0, 3)]);
        assert_eq!(spans("a:\n\u{3000}\n  b\n"), [(0, 3)]);
    }

    #[test]
    fn test_compute_viewport_empty_and_out_of_bounds() {
        let rope = Rope::from_str("");
        assert!(compute_viewport(&rope, 0, 10, 2).is_empty());
        let rope = Rope::from_str("a:\n  b\n");
        assert_eq!(compute_viewport(&rope, 100, 200, 2).len(), 1);
    }
}
