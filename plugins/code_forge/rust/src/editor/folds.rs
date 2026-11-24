use crate::api::editor::RustFoldRange;
use ropey::{Rope, RopeSlice};

const BRACKET_ACTION: [u8; 256] = {
    let mut table = [0u8; 256];
    table[b'\n' as usize] = 1;
    table[b'{' as usize] = 2;
    table[b'}' as usize] = 3;
    table[b'[' as usize] = 4;
    table[b']' as usize] = 5;
    table[b'(' as usize] = 6;
    table[b')' as usize] = 7;
    table
};

pub fn compute_all(rope: &Rope, tab_size: usize) -> Vec<RustFoldRange> {
    let mut folds = Vec::with_capacity(rope.len_lines() / 4);
    bracket_folds(rope, &mut folds);
    indent_folds(rope, tab_size, &mut folds);
    folds.sort_unstable_by(|a, b| {
        a.start_line
            .cmp(&b.start_line)
            .then_with(|| a.end_line.cmp(&b.end_line))
    });
    folds.dedup_by(|b, a| a.start_line == b.start_line);
    folds
}

fn bracket_folds(rope: &Rope, folds: &mut Vec<RustFoldRange>) {
    let mut open: [Vec<i32>; 3] = Default::default();
    let mut line_idx: i32 = 0;
    for chunk in rope.chunks() {
        for &b in chunk.as_bytes() {
            let action = BRACKET_ACTION[b as usize];
            if action == 0 {
                continue;
            }
            if action == 1 {
                line_idx += 1;
                continue;
            }
            let kind = ((action - 2) >> 1) as usize;
            if (action & 1) == 0 {
                open[kind].push(line_idx);
            } else if let Some(start_line) = open[kind].pop() {
                if start_line < line_idx {
                    folds.push(RustFoldRange {
                        start_line,
                        end_line: line_idx,
                    });
                }
            }
        }
    }
}

fn indent_folds(rope: &Rope, tab_size: usize, folds: &mut Vec<RustFoldRange>) {
    let mut open: Vec<(usize, usize)> = Vec::with_capacity(16);
    let mut last_content = 0;
    for (line_idx, line) in rope.lines().enumerate() {
        let Some((indent, ends_with_colon)) = scan_line(line, tab_size) else {
            continue;
        };
        while let Some(&(start, start_indent)) = open.last() {
            if indent > start_indent {
                break;
            }
            open.pop();
            close(start, last_content, folds);
        }
        if ends_with_colon {
            open.push((line_idx, indent));
        }
        last_content = line_idx;
    }
    for (start, _) in open {
        close(start, last_content, folds);
    }
}

#[inline(always)]
fn close(start: usize, end: usize, folds: &mut Vec<RustFoldRange>) {
    if end > start {
        folds.push(RustFoldRange {
            start_line: start as i32,
            end_line: end as i32,
        });
    }
}

#[inline(always)]
fn is_non_blank_char(ch: char) -> bool {
    !ch.is_whitespace() && ch != '\u{feff}'
}

#[inline(always)]
fn scan_line_str(s: &str, tab_size: usize) -> Option<(usize, bool)> {
    let bytes = s.as_bytes();
    let len = bytes.len();
    let mut i = 0;
    let mut indent = 0;
    if tab_size > 0 {
        while i < len {
            match bytes[i] {
                b' ' => indent += 1,
                b'\t' => indent += tab_size - indent % tab_size,
                _ => break,
            }
            i += 1;
        }
    } else {
        while i < len {
            match bytes[i] {
                b' ' | b'\t' => indent += 1,
                _ => break,
            }
            i += 1;
        }
    }
    let mut end = len;
    while end > i && matches!(bytes[end - 1], b' ' | b'\t'..=b'\r') {
        end -= 1;
    }
    if end == i {
        return None;
    }
    let last_byte = bytes[end - 1];
    if last_byte < 128 {
        return Some((indent, last_byte == b':'));
    }
    s[i..end]
        .chars()
        .rev()
        .find(|&ch| is_non_blank_char(ch))
        .map(|ch| (indent, ch == ':'))
}

#[inline(always)]
fn scan_line(line: RopeSlice, tab_size: usize) -> Option<(usize, bool)> {
    if let Some(s) = line.as_str() {
        return scan_line_str(s, tab_size);
    }
    let s = line.to_string();
    scan_line_str(&s, tab_size)
}

pub fn find_matching_bracket(rope: &Rope, target_offset: usize) -> Option<usize> {
    let len = rope.len_chars();
    if target_offset >= len {
        return None;
    }
    let start_ch: char = rope.char(target_offset);
    let mut depth = 1usize;
    match start_ch {
        '{' | '[' | '(' => {
            let matcher_ch = match start_ch {
                '{' => '}',
                '[' => ']',
                _ => ')',
            };
            for (i, ch) in rope.chars_at(target_offset + 1).enumerate() {
                let idx = target_offset + 1 + i;
                if ch == start_ch {
                    depth += 1;
                } else if ch == matcher_ch {
                    depth -= 1;
                    if depth == 0 {
                        return Some(idx);
                    }
                }
            }
        }
        '}' | ']' | ')' => {
            let start_byte = start_ch as u8;
            let matcher_byte = match start_ch {
                '}' => b'{',
                ']' => b'[',
                _ => b'(',
            };
            let is_ascii_doc = rope.len_bytes() == len;
            let mut byte_offset = if is_ascii_doc {
                target_offset
            } else {
                rope.char_to_byte(target_offset)
            };
            let slice = rope.slice(..target_offset);
            let (mut chunks, _, _, _) = slice.chunks_at_byte(slice.len_bytes());
            while let Some(chunk) = chunks.prev() {
                let bytes = chunk.as_bytes();
                byte_offset -= bytes.len();
                for (i, &b) in bytes.iter().enumerate().rev() {
                    if b == start_byte {
                        depth += 1;
                    } else if b == matcher_byte {
                        depth -= 1;
                        if depth == 0 {
                            let match_byte = byte_offset + i;
                            return Some(if is_ascii_doc {
                                match_byte
                            } else {
                                rope.byte_to_char(match_byte)
                            });
                        }
                    }
                }
            }
        }
        _ => return None,
    }
    None
}

#[cfg(test)]
mod tests {
    use super::*;

    fn folds(text: &str) -> Vec<(i32, i32)> {
        compute_all(&Rope::from_str(text), 2)
            .into_iter()
            .map(|fold| (fold.start_line, fold.end_line))
            .collect()
    }

    #[test]
    fn a_key_folds_over_its_deeper_lines_across_blank_ones() {
        let text = "proxies:\n  - name: a\n    ws-opts:\n      path: /\n\n  - name: b\nrules:\n  - MATCH,DIRECT\n\n";
        assert_eq!(folds(text), [(0, 5), (2, 3), (6, 7)]);
    }

    #[test]
    fn a_key_without_deeper_lines_does_not_fold() {
        assert_eq!(folds("a:\nb: 1\nc:\n"), []);
    }

    #[test]
    fn a_byte_order_mark_counts_as_blank() {
        assert_eq!(folds("a:\u{feff}\n  b\nc\n"), [(0, 1)]);
        assert_eq!(folds("a:\n  b\n\u{feff}\n  c\nd\n"), [(0, 3)]);
    }

    #[test]
    fn a_line_with_both_keeps_the_smaller_fold() {
        assert_eq!(folds("f(a,\n  b:\n    c\n  d)\n"), [(0, 3), (1, 2)]);
        assert_eq!(folds("x: {\n  a: 1\n}\n"), [(0, 2)]);
    }

    #[test]
    fn a_stray_bracket_leaves_the_other_kinds_their_folds() {
        assert_eq!(folds("a {\n  b (\n}\n"), [(0, 2)]);
        assert_eq!(folds("a [\n  b )\n]\n"), [(0, 2)]);
        assert_eq!(folds("f(x, [\n  y)\n]\n"), [(0, 1)]);
    }

    #[test]
    fn test_matching_bracket_forward_and_backward() {
        let r = Rope::from_str("function test(a, [b, { c: 1 }]) { return (a + b); }");
        assert_eq!(find_matching_bracket(&r, 13), Some(30));
        assert_eq!(find_matching_bracket(&r, 30), Some(13));
        assert_eq!(find_matching_bracket(&r, 17), Some(29));
        assert_eq!(find_matching_bracket(&r, 29), Some(17));
        assert_eq!(find_matching_bracket(&r, 21), Some(28));
        assert_eq!(find_matching_bracket(&r, 28), Some(21));
        assert_eq!(find_matching_bracket(&r, 32), Some(50));
        assert_eq!(find_matching_bracket(&r, 50), Some(32));
        assert_eq!(find_matching_bracket(&r, 41), Some(47));
        assert_eq!(find_matching_bracket(&r, 47), Some(41));
        assert_eq!(find_matching_bracket(&r, 0), None);
        assert_eq!(find_matching_bracket(&r, 999), None);
    }
}
