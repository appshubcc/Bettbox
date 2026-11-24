use ropey::{Rope, RopeBuilder, RopeSlice};
use std::borrow::Cow;
use std::fs::File;
use std::io::{self, Read};
use std::sync::{RwLock, RwLockReadGuard};

pub struct Buffer {
    rope: RwLock<Rope>,
}

impl Buffer {
    pub fn new(initial_text: &str) -> Self {
        Self {
            rope: RwLock::new(Rope::from_str(initial_text)),
        }
    }

    pub fn from_normalized(initial_text: &str) -> Self {
        if !initial_text.as_bytes().contains(&b'\r') {
            return Self::new(initial_text);
        }
        let mut builder = RopeBuilder::new();
        append_normalized(&mut builder, initial_text);
        Self {
            rope: RwLock::new(builder.finish()),
        }
    }

    pub fn from_file(path: &str) -> io::Result<Self> {
        let mut file = File::open(path)?;
        let mut builder = RopeBuilder::new();
        let mut buf = vec![0u8; 64 * 1024];
        let mut leftover = 0usize;
        let mut pending_cr = false;

        loop {
            let read = file.read(&mut buf[leftover..])?;
            if read == 0 {
                if pending_cr {
                    builder.append("\n");
                }
                if leftover > 0 {
                    return Err(io::Error::new(
                        io::ErrorKind::InvalidData,
                        "Invalid UTF-8 sequence at EOF",
                    ));
                }
                break;
            }
            let total = leftover + read;
            let valid_len = match std::str::from_utf8(&buf[..total]) {
                Ok(_) => total,
                Err(err) => {
                    if err.error_len().is_some() {
                        return Err(io::Error::new(
                            io::ErrorKind::InvalidData,
                            "Invalid UTF-8 sequence",
                        ));
                    }
                    err.valid_up_to()
                }
            };
            if valid_len > 0 {
                let mut chunk =
                    std::str::from_utf8(&buf[..valid_len]).expect("validated UTF-8 prefix");
                if pending_cr {
                    pending_cr = false;
                    if let Some(stripped) = chunk.strip_prefix('\n') {
                        chunk = stripped;
                    }
                    builder.append("\n");
                }
                if let Some(stripped) = chunk.strip_suffix('\r') {
                    pending_cr = true;
                    chunk = stripped;
                }
                if !chunk.is_empty() {
                    append_normalized(&mut builder, chunk);
                }
            }
            buf.copy_within(valid_len..total, 0);
            leftover = total - valid_len;
        }

        Ok(Self {
            rope: RwLock::new(builder.finish()),
        })
    }

    pub fn rope(&self) -> RwLockReadGuard<'_, Rope> {
        self.rope.read().unwrap()
    }

    pub fn snapshot(&self) -> Rope {
        self.rope().clone()
    }

    pub fn live_rope(
        &self,
        dirty_start: usize,
        dirty_end: usize,
        dirty_text: Option<&str>,
    ) -> Rope {
        let mut rope = self.snapshot();
        if let Some(text) = dirty_text {
            let len = rope.len_chars();
            let start = dirty_start.min(len);
            let end = dirty_end.max(start).min(len);
            if start < end {
                rope.remove(start..end);
            }
            if !text.is_empty() {
                let normalized = normalize_str(text);
                rope.insert(start, &normalized);
            }
        }
        rope
    }

    pub fn len_chars(&self) -> usize {
        self.rope().len_chars()
    }

    pub fn text(&self) -> String {
        self.rope().to_string()
    }

    pub fn insert(&self, char_idx: usize, text: &str) {
        if text.is_empty() {
            return;
        }
        let mut rope = self.rope.write().unwrap();
        let idx = char_idx.min(rope.len_chars());
        rope.insert(idx, text);
    }

    pub fn remove(&self, start: usize, end: usize) {
        if start >= end {
            return;
        }
        let mut rope = self.rope.write().unwrap();
        let len = rope.len_chars();
        if start >= len {
            return;
        }
        rope.remove(start..end.min(len));
    }

    pub fn slice(&self, start: usize, end: usize) -> String {
        let rope = self.rope();
        let len = rope.len_chars();
        let valid_start = start.min(len);
        let valid_end = end.max(valid_start).min(len);
        if valid_start == valid_end {
            return String::new();
        }
        let slice = rope.slice(valid_start..valid_end);
        match slice.as_str() {
            Some(s) => s.to_owned(),
            None => slice.to_string(),
        }
    }

    pub fn char_to_line(&self, char_idx: usize) -> usize {
        let rope = self.rope();
        rope.char_to_line(char_idx.min(rope.len_chars()))
    }

    pub fn line_to_char(&self, line_idx: usize) -> usize {
        let rope = self.rope();
        rope.line_to_char(line_idx.min(rope.len_lines().saturating_sub(1)))
    }

    pub fn line(&self, line_idx: usize) -> String {
        let rope = self.rope();
        let valid_idx = line_idx.min(rope.len_lines().saturating_sub(1));
        line_without_break(&rope, valid_idx)
    }

    pub fn len_lines(&self) -> usize {
        self.rope().len_lines()
    }

    pub fn lines(&self, start_line: usize, end_line: usize) -> Vec<String> {
        let rope = self.rope();
        let total = rope.len_lines();
        let start = start_line.min(total);
        let end = end_line.min(total).max(start);
        let count = end - start;
        let mut result = Vec::with_capacity(count);
        result.extend(rope.lines_at(start).take(count).map(trim_line_break));
        result
    }
}

pub(crate) fn normalize_str(text: &str) -> Cow<'_, str> {
    if !text.as_bytes().contains(&b'\r') {
        return Cow::Borrowed(text);
    }
    let mut out = String::with_capacity(text.len());
    let bytes = text.as_bytes();
    let mut start = 0usize;
    let mut i = 0usize;
    while i < bytes.len() {
        if bytes[i] == b'\r' {
            out.push_str(&text[start..i]);
            out.push('\n');
            if i + 1 < bytes.len() && bytes[i + 1] == b'\n' {
                i += 2;
            } else {
                i += 1;
            }
            start = i;
        } else {
            i += 1;
        }
    }
    out.push_str(&text[start..]);
    Cow::Owned(out)
}

fn append_normalized(builder: &mut RopeBuilder, text: &str) {
    if !text.as_bytes().contains(&b'\r') {
        builder.append(text);
        return;
    }
    let bytes = text.as_bytes();
    let mut start = 0usize;
    let mut i = 0usize;
    while i < bytes.len() {
        if bytes[i] == b'\r' {
            if start < i {
                builder.append(&text[start..i]);
            }
            builder.append("\n");
            if i + 1 < bytes.len() && bytes[i + 1] == b'\n' {
                i += 2;
            } else {
                i += 1;
            }
            start = i;
        } else {
            i += 1;
        }
    }
    if start < bytes.len() {
        builder.append(&text[start..]);
    }
}

pub fn ropes_equal(a: &Rope, b: &Rope) -> bool {
    if a.len_bytes() != b.len_bytes() || a.len_chars() != b.len_chars() {
        return false;
    }
    let mut chunks_a = a.chunks();
    let mut chunks_b = b.chunks();
    let mut rem_a: &[u8] = &[];
    let mut rem_b: &[u8] = &[];
    loop {
        while rem_a.is_empty() {
            match chunks_a.next() {
                Some(c) => rem_a = c.as_bytes(),
                None => break,
            }
        }
        while rem_b.is_empty() {
            match chunks_b.next() {
                Some(c) => rem_b = c.as_bytes(),
                None => break,
            }
        }
        if rem_a.is_empty() && rem_b.is_empty() {
            return true;
        }
        if rem_a.is_empty() != rem_b.is_empty() {
            return false;
        }
        let n = rem_a.len().min(rem_b.len());
        if rem_a.as_ptr() != rem_b.as_ptr() && rem_a[..n] != rem_b[..n] {
            return false;
        }
        rem_a = &rem_a[n..];
        rem_b = &rem_b[n..];
    }
}

pub fn diff_slice_and_str(slice: RopeSlice<'_>, new_text: &str) -> Option<(u32, u32, String)> {
    let normalized = normalize_str(new_text);
    let new_bytes = normalized.as_bytes();
    let old_len = slice.len_bytes();
    let new_len = new_bytes.len();

    let mut prefix_byte = 0usize;
    for chunk in slice.chunks() {
        let cb = chunk.as_bytes();
        let rem = &new_bytes[prefix_byte..];
        let limit = cb.len().min(rem.len());
        let matched = cb[..limit]
            .iter()
            .zip(&rem[..limit])
            .position(|(a, b)| a != b)
            .unwrap_or(limit);
        prefix_byte += matched;
        if matched < cb.len() || prefix_byte == new_len {
            break;
        }
    }

    if prefix_byte == old_len && old_len == new_len {
        return None;
    }

    while prefix_byte > 0 && !normalized.is_char_boundary(prefix_byte) {
        prefix_byte -= 1;
    }

    let max_suffix = (old_len - prefix_byte).min(new_len - prefix_byte);
    let mut suffix_bytes = 0usize;
    if max_suffix > 0 {
        let (mut chunks, _, _, _) = slice.chunks_at_byte(old_len);
        while suffix_bytes < max_suffix {
            let Some(chunk) = chunks.prev() else { break };
            let cb = chunk.as_bytes();
            if cb.is_empty() {
                continue;
            }
            let limit = cb.len().min(max_suffix - suffix_bytes);
            let cb_tail = &cb[cb.len() - limit..];
            let new_tail_end = new_len - suffix_bytes;
            let new_tail = &new_bytes[new_tail_end - limit..new_tail_end];
            let mut matched = 0usize;
            while matched < limit && cb_tail[limit - 1 - matched] == new_tail[limit - 1 - matched] {
                matched += 1;
            }
            suffix_bytes += matched;
            if matched < limit {
                break;
            }
        }
    }

    let mut new_end = new_len - suffix_bytes;
    while new_end < new_len && !normalized.is_char_boundary(new_end) {
        new_end += 1;
    }
    let actual_suffix = new_len - new_end;
    let old_end = old_len - actual_suffix;
    let start_scalar = slice.byte_to_char(prefix_byte) as u32;
    let end_scalar = slice.byte_to_char(old_end) as u32;
    Some((
        start_scalar,
        end_scalar,
        normalized[prefix_byte..new_end].to_owned(),
    ))
}

pub(super) fn line_without_break(rope: &Rope, line_idx: usize) -> String {
    trim_line_break(rope.line(line_idx))
}

fn trim_line_break(line: RopeSlice<'_>) -> String {
    if let Some(s) = line.as_str() {
        return s
            .strip_suffix("\r\n")
            .or_else(|| s.strip_suffix('\n'))
            .unwrap_or(s)
            .to_owned();
    }
    let len = line.len_chars();
    let trim = if len > 0 && line.char(len - 1) == '\n' {
        if len > 1 && line.char(len - 2) == '\r' {
            2
        } else {
            1
        }
    } else {
        0
    };
    line.slice(..len - trim).to_string()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn edits_out_of_bounds_are_clamped() {
        let buffer = Buffer::new("abc");
        buffer.insert(10, "d");
        buffer.remove(2, 10);
        buffer.remove(3, 1);
        assert_eq!(buffer.text(), "ab");
    }

    #[test]
    fn test_lines_and_slices_crlf_and_lf() {
        let text = "line 1\r\nline 2\nline 3\r\n\r\nlast line";
        let buffer = Buffer::new(text);
        assert_eq!(buffer.len_lines(), 5);
        assert_eq!(
            buffer.lines(0, 5),
            vec!["line 1", "line 2", "line 3", "", "last line"]
        );
        assert_eq!(buffer.lines(1, 3), vec!["line 2", "line 3"]);
        assert_eq!(buffer.lines(4, 10), vec!["last line"]);
        assert_eq!(buffer.lines(5, 10), Vec::<String>::new());
        assert_eq!(buffer.lines(3, 3), Vec::<String>::new());

        assert_eq!(buffer.slice(0, 6), "line 1");
        assert_eq!(buffer.slice(0, 0), "");
        assert_eq!(buffer.slice(100, 200), "");
    }

    #[test]
    fn normalized_and_streaming_file_loader_handle_crlf_and_unicode() {
        let raw = format!(
            "header: 1\r\n{}\rsolo_cr\n😀尾行\r",
            "  - DOMAIN-SUFFIX,example.com,PROXY\r\n".repeat(2500)
        );
        let expected = raw.replace("\r\n", "\n").replace('\r', "\n");
        let mem_buf = Buffer::from_normalized(&raw);
        assert_eq!(mem_buf.text(), expected);

        let temp_path = std::env::temp_dir().join(format!(
            "code_forge_buffer_test_{}.yaml",
            std::process::id()
        ));
        std::fs::write(&temp_path, raw.as_bytes()).unwrap();
        let file_buf = Buffer::from_file(temp_path.to_str().unwrap()).unwrap();
        let _ = std::fs::remove_file(&temp_path);

        assert!(ropes_equal(&mem_buf.rope(), &file_buf.rope()));
    }

    #[test]
    fn ropes_equal_and_diff_handle_multibyte_and_multi_chunk() {
        let base = format!(
            "{}😀middle🚀{}",
            "line: 7890\n".repeat(400),
            "tail: ok\n".repeat(400)
        );
        let buf = Buffer::from_normalized(&base);
        let snap = buf.snapshot();
        assert!(ropes_equal(&buf.rope(), &snap));

        let same_len_modified = base.replacen("7890", "7891", 1);
        let other = Buffer::from_normalized(&same_len_modified);
        assert!(!ropes_equal(&other.rope(), &snap));

        let emoji_swapped = base.replacen("😀", "🚀", 1);
        let (start, end, rep) = diff_slice_and_str(buf.rope().slice(..), &emoji_swapped).unwrap();
        buf.remove(start as usize, end as usize);
        buf.insert(start as usize, &rep);
        assert_eq!(buf.text(), emoji_swapped);
        assert!(diff_slice_and_str(buf.rope().slice(..), &emoji_swapped).is_none());
    }
}
