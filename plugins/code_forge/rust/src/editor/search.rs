use super::buffer::{diff_slice_and_str, normalize_str};
use fancy_regex::{Regex, RegexBuilder};
use ropey::{Rope, RopeSlice};
use std::sync::Mutex;

const BACKTRACK_LIMIT: usize = 200_000;

#[derive(Clone, PartialEq, Eq)]
pub struct Query {
    pub pattern: String,
    pub is_regex: bool,
    pub case_sensitive: bool,
    pub whole_word: bool,
}

static COMPILED: Mutex<Option<(Query, Regex)>> = Mutex::new(None);

fn compile(query: &Query) -> Option<Regex> {
    let mut cached = COMPILED
        .lock()
        .unwrap_or_else(|poisoned| poisoned.into_inner());
    if let Some((key, regex)) = cached.as_ref() {
        if key == query {
            return Some(regex.clone());
        }
    }
    let mut full_pattern = String::with_capacity(query.pattern.len() + 16);
    full_pattern.push_str(if query.case_sensitive {
        "(?m)"
    } else {
        "(?mi)"
    });
    if query.whole_word {
        full_pattern.push_str(r"\b");
    }
    if query.is_regex {
        full_pattern.push_str(&query.pattern);
    } else {
        full_pattern.push_str(&fancy_regex::escape(&query.pattern));
    }
    if query.whole_word {
        full_pattern.push_str(r"\b");
    }
    let regex = RegexBuilder::new(&full_pattern)
        .backtrack_limit(BACKTRACK_LIMIT)
        .build()
        .ok()?;
    *cached = Some((query.clone(), regex.clone()));
    Some(regex)
}

#[inline(always)]
fn can_use_ascii_ci(text: &str, text_is_ascii: bool, pat: &str) -> bool {
    if !pat.is_ascii() {
        return false;
    }
    if text_is_ascii || !pat.bytes().any(|b| matches!(b, b's' | b'S' | b'k' | b'K')) {
        return true;
    }
    !text.contains('\u{017f}') && !text.contains('\u{212a}')
}

#[inline(always)]
fn find_next_ascii_ci(
    haystack: &[u8],
    needle: &[u8],
    from: usize,
    first_lo: u8,
    first_hi: u8,
    last_lo: u8,
    last_hi: u8,
) -> Option<usize> {
    let m = needle.len();
    if haystack.len() < m || from > haystack.len() - m {
        return None;
    }
    let limit = haystack.len() - m;
    let mut pos = from;
    if m == 1 {
        if first_lo == first_hi {
            return haystack[pos..]
                .iter()
                .position(|&b| b == first_lo)
                .map(|o| pos + o);
        }
        return haystack[pos..]
            .iter()
            .position(|&b| b == first_lo || b == first_hi)
            .map(|o| pos + o);
    }
    let mid_needle = &needle[1..m - 1];
    while pos <= limit {
        let offset = if first_lo == first_hi {
            haystack[pos..=limit].iter().position(|&b| b == first_lo)?
        } else {
            haystack[pos..=limit]
                .iter()
                .position(|&b| b == first_lo || b == first_hi)?
        };
        let idx = pos + offset;
        let bl = haystack[idx + m - 1];
        if (bl == last_lo || bl == last_hi)
            && haystack[idx + 1..idx + m - 1].eq_ignore_ascii_case(mid_needle)
        {
            return Some(idx);
        }
        pos = idx + 1;
    }
    None
}

pub struct ReplaceAllEdit {
    pub start_scalar: u32,
    pub end_scalar: u32,
    pub replacement: String,
}

fn find_plain_cs_into(
    text: &str,
    text_is_ascii: bool,
    pat: &str,
    base: u32,
    ranges: &mut Vec<u32>,
) {
    if text_is_ascii {
        let pat_len = pat.len() as u32;
        for (start, _) in text.match_indices(pat) {
            let s = base + start as u32;
            ranges.push(s);
            ranges.push(s + pat_len);
        }
    } else {
        let pat_scalars = pat.chars().count() as u32;
        let mut byte = 0;
        let mut scalar = base;
        for (start, _) in text.match_indices(pat) {
            scalar += text[byte..start].chars().count() as u32;
            let end = scalar + pat_scalars;
            ranges.push(scalar);
            ranges.push(end);
            byte = start + pat.len();
            scalar = end;
        }
    }
}

fn find_plain_ascii_ci_into(
    text: &str,
    text_is_ascii: bool,
    needle: &[u8],
    first_lo: u8,
    first_hi: u8,
    last_lo: u8,
    last_hi: u8,
    base: u32,
    ranges: &mut Vec<u32>,
) {
    let bytes = text.as_bytes();
    let m = needle.len();
    let mut pos = 0;
    if text_is_ascii {
        let pat_len = m as u32;
        while let Some(start) =
            find_next_ascii_ci(bytes, needle, pos, first_lo, first_hi, last_lo, last_hi)
        {
            let s = base + start as u32;
            ranges.push(s);
            ranges.push(s + pat_len);
            pos = start + m;
        }
    } else {
        let pat_scalars = m as u32;
        let mut scalar = base;
        while let Some(start) =
            find_next_ascii_ci(bytes, needle, pos, first_lo, first_hi, last_lo, last_hi)
        {
            scalar += text[pos..start].chars().count() as u32;
            let end = scalar + pat_scalars;
            ranges.push(scalar);
            ranges.push(end);
            pos = start + m;
            scalar = end;
        }
    }
}

fn find_regex_into(
    text: &str,
    text_is_ascii: bool,
    regex: &Regex,
    base: u32,
    ranges: &mut Vec<u32>,
) {
    if text_is_ascii {
        for found in regex.find_iter(text) {
            let Ok(found) = found else { break };
            ranges.push(base + found.start() as u32);
            ranges.push(base + found.end() as u32);
        }
    } else {
        let mut byte = 0;
        let mut scalar = base;
        for found in regex.find_iter(text) {
            let Ok(found) = found else { break };
            let start_byte = found.start();
            let end_byte = found.end();
            scalar += text[byte..start_byte].chars().count() as u32;
            let end = scalar + text[start_byte..end_byte].chars().count() as u32;
            ranges.push(scalar);
            ranges.push(end);
            byte = end_byte;
            scalar = end;
        }
    }
}

pub fn find(text: &str, query: &Query) -> Option<Vec<u32>> {
    let pat = query.pattern.as_str();
    let is_plain = !query.is_regex && !query.whole_word && !pat.is_empty();
    let text_is_ascii = text.is_ascii();

    if is_plain {
        if query.case_sensitive {
            let mut ranges = Vec::new();
            find_plain_cs_into(text, text_is_ascii, pat, 0, &mut ranges);
            return Some(ranges);
        } else if can_use_ascii_ci(text, text_is_ascii, pat) {
            let needle = pat.as_bytes();
            let m = needle.len();
            let first_lo = needle[0].to_ascii_lowercase();
            let first_hi = needle[0].to_ascii_uppercase();
            let last_lo = needle[m - 1].to_ascii_lowercase();
            let last_hi = needle[m - 1].to_ascii_uppercase();
            let mut ranges = Vec::new();
            find_plain_ascii_ci_into(
                text,
                text_is_ascii,
                needle,
                first_lo,
                first_hi,
                last_lo,
                last_hi,
                0,
                &mut ranges,
            );
            return Some(ranges);
        }
    }

    let regex = compile(query)?;
    let mut ranges = Vec::new();
    find_regex_into(text, text_is_ascii, &regex, 0, &mut ranges);
    Some(ranges)
}

fn skip_scalars(s: &str, count: usize) -> &str {
    if count == 0 {
        return s;
    }
    match s.char_indices().nth(count) {
        Some((byte_idx, _)) => &s[byte_idx..],
        None => "",
    }
}

fn find_plain_in_chunks(slice: RopeSlice<'_>, pat: &str, case_sensitive: bool) -> Option<Vec<u32>> {
    if !case_sensitive && !pat.is_ascii() {
        return None;
    }
    let m = pat.len();
    let needle = pat.as_bytes();
    let first_lo = needle[0].to_ascii_lowercase();
    let first_hi = needle[0].to_ascii_uppercase();
    let last_lo = needle[m - 1].to_ascii_lowercase();
    let last_hi = needle[m - 1].to_ascii_uppercase();

    let mut ranges = Vec::new();
    let mut chunk_base = 0u32;
    let mut next_allowed = 0u32;
    let mut overlap = String::new();
    let mut overlap_base = 0u32;
    let mut window = String::new();
    let mut window_matches = Vec::new();

    for chunk in slice.chunks() {
        if chunk.is_empty() {
            continue;
        }
        let chunk_ascii = chunk.is_ascii();
        if !case_sensitive && !can_use_ascii_ci(chunk, chunk_ascii, pat) {
            return None;
        }
        let chunk_chars = if chunk_ascii {
            chunk.len() as u32
        } else {
            chunk.chars().count() as u32
        };

        if m > 1 && !overlap.is_empty() {
            if overlap.len() + chunk.len() < m {
                overlap.push_str(chunk);
                chunk_base += chunk_chars;
                continue;
            }
            let mut take = (m - 1).min(chunk.len());
            while take < chunk.len() && !chunk.is_char_boundary(take) {
                take += 1;
            }
            window.clear();
            window.push_str(&overlap);
            window.push_str(&chunk[..take]);
            window_matches.clear();
            let win_ascii = overlap.is_ascii() && (chunk_ascii || chunk[..take].is_ascii());
            let win_skip = next_allowed.saturating_sub(overlap_base) as usize;
            let win_text = if win_skip == 0 {
                window.as_str()
            } else if win_ascii {
                &window[win_skip.min(window.len())..]
            } else {
                skip_scalars(&window, win_skip)
            };
            let win_base = overlap_base + win_skip as u32;
            if case_sensitive {
                find_plain_cs_into(win_text, win_ascii, pat, win_base, &mut window_matches);
            } else {
                find_plain_ascii_ci_into(
                    win_text,
                    win_ascii,
                    needle,
                    first_lo,
                    first_hi,
                    last_lo,
                    last_hi,
                    win_base,
                    &mut window_matches,
                );
            }
            let overlap_end_scalar = chunk_base;
            let mut idx = 0usize;
            while idx < window_matches.len() {
                let s = window_matches[idx];
                let e = window_matches[idx + 1];
                if s >= overlap_end_scalar {
                    break;
                }
                if s >= next_allowed {
                    ranges.push(s);
                    ranges.push(e);
                    next_allowed = e;
                }
                idx += 2;
            }
        }

        let skip = next_allowed.saturating_sub(chunk_base) as usize;
        if (skip as u32) < chunk_chars {
            let sub = if skip == 0 {
                chunk
            } else if chunk_ascii {
                &chunk[skip..]
            } else {
                skip_scalars(chunk, skip)
            };
            let sub_base = chunk_base + skip as u32;
            if case_sensitive {
                find_plain_cs_into(sub, chunk_ascii, pat, sub_base, &mut ranges);
            } else {
                find_plain_ascii_ci_into(
                    sub,
                    chunk_ascii,
                    needle,
                    first_lo,
                    first_hi,
                    last_lo,
                    last_hi,
                    sub_base,
                    &mut ranges,
                );
            }
            if let Some(&last_end) = ranges.last() {
                if last_end > next_allowed {
                    next_allowed = last_end;
                }
            }
        }

        let chunk_end = chunk_base + chunk_chars;
        if m > 1 {
            if chunk.len() >= m - 1 {
                let mut tail_start = chunk.len() - (m - 1);
                while tail_start > 0 && !chunk.is_char_boundary(tail_start) {
                    tail_start -= 1;
                }
                let tail = &chunk[tail_start..];
                let tail_chars = if chunk_ascii {
                    tail.len() as u32
                } else {
                    tail.chars().count() as u32
                };
                overlap.clear();
                overlap.push_str(tail);
                overlap_base = chunk_end - tail_chars;
            } else {
                overlap.push_str(chunk);
                if overlap.len() > m - 1 {
                    let mut drop_to = overlap.len() - (m - 1);
                    while drop_to > 0 && !overlap.is_char_boundary(drop_to) {
                        drop_to -= 1;
                    }
                    let dropped_chars = overlap[..drop_to].chars().count() as u32;
                    overlap.drain(..drop_to);
                    overlap_base += dropped_chars;
                }
            }
        }
        chunk_base = chunk_end;
    }

    Some(ranges)
}

pub fn find_in_slice(slice: RopeSlice<'_>, query: &Query) -> Option<Vec<u32>> {
    if let Some(s) = slice.as_str() {
        return find(s, query);
    }

    let pat = query.pattern.as_str();
    if !query.is_regex && !query.whole_word && !pat.is_empty() {
        if let Some(ranges) = find_plain_in_chunks(slice, pat, query.case_sensitive) {
            return Some(ranges);
        }
    }

    if !query.is_regex && !pat.is_empty() && !pat.contains('\n') && !pat.contains('\r') {
        let regex = compile(query)?;
        let mut ranges = Vec::new();
        let mut scratch = String::new();
        let mut line_base = 0u32;
        for line in slice.lines() {
            let line_chars = line.len_chars() as u32;
            let raw = match line.as_str() {
                Some(s) => s,
                None => {
                    scratch.clear();
                    for chunk in line.chunks() {
                        scratch.push_str(chunk);
                    }
                    scratch.as_str()
                }
            };
            let line_str = raw
                .strip_suffix("\r\n")
                .or_else(|| raw.strip_suffix('\n'))
                .unwrap_or(raw);
            if !line_str.is_empty() {
                find_regex_into(
                    line_str,
                    line_str.is_ascii(),
                    &regex,
                    line_base,
                    &mut ranges,
                );
            }
            line_base += line_chars;
        }
        return Some(ranges);
    }

    let regex = compile(query)?;
    let text = slice.to_string();
    let mut ranges = Vec::new();
    find_regex_into(&text, text.is_ascii(), &regex, 0, &mut ranges);
    Some(ranges)
}

pub fn replace_all_in_rope(
    rope: &Rope,
    query: &Query,
    replacement: &str,
) -> Option<ReplaceAllEdit> {
    let ranges = find_in_slice(rope.slice(..), query)?;
    if ranges.is_empty() {
        return None;
    }
    let normalized_rep = normalize_str(replacement);
    let first_start = ranges[0] as usize;
    let last_end = ranges[ranges.len() - 1] as usize;
    let orig_span = rope.slice(first_start..last_end);

    let match_count = ranges.len() / 2;
    let mut replaced_span =
        String::with_capacity(orig_span.len_bytes() + match_count * normalized_rep.len());
    let mut cursor = first_start;
    let mut i = 0usize;
    while i < ranges.len() {
        let m_start = ranges[i] as usize;
        let m_end = ranges[i + 1] as usize;
        if cursor < m_start {
            for chunk in rope.slice(cursor..m_start).chunks() {
                replaced_span.push_str(chunk);
            }
        }
        replaced_span.push_str(&normalized_rep);
        cursor = m_end;
        i += 2;
    }

    let (trim_start, trim_end, trimmed) = diff_slice_and_str(orig_span, &replaced_span)?;
    let base = first_start as u32;
    Some(ReplaceAllEdit {
        start_scalar: base + trim_start,
        end_scalar: base + trim_end,
        replacement: trimmed,
    })
}

/// The text with every match replaced by `replacement` taken literally.
pub fn replace_all(text: &str, query: &Query, replacement: &str) -> Option<String> {
    let pat = query.pattern.as_str();
    let is_plain = !query.is_regex && !query.whole_word && !pat.is_empty();

    if is_plain {
        let m = pat.len();
        if query.case_sensitive {
            let mut starts = Vec::new();
            for (start, _) in text.match_indices(pat) {
                starts.push(start);
            }
            if starts.is_empty() {
                return Some(text.to_string());
            }
            let exact_len = text.len() - starts.len() * m + starts.len() * replacement.len();
            let mut result = String::with_capacity(exact_len);
            let mut byte = 0;
            for start in starts {
                result.push_str(&text[byte..start]);
                result.push_str(replacement);
                byte = start + m;
            }
            result.push_str(&text[byte..]);
            return Some(result);
        } else if can_use_ascii_ci(text, text.is_ascii(), pat) {
            let bytes = text.as_bytes();
            let needle = pat.as_bytes();
            let first_lo = needle[0].to_ascii_lowercase();
            let first_hi = needle[0].to_ascii_uppercase();
            let last_lo = needle[m - 1].to_ascii_lowercase();
            let last_hi = needle[m - 1].to_ascii_uppercase();
            let mut starts = Vec::new();
            let mut pos = 0;
            while let Some(start) =
                find_next_ascii_ci(bytes, needle, pos, first_lo, first_hi, last_lo, last_hi)
            {
                starts.push(start);
                pos = start + m;
            }
            if starts.is_empty() {
                return Some(text.to_string());
            }
            let exact_len = text.len() - starts.len() * m + starts.len() * replacement.len();
            let mut result = String::with_capacity(exact_len);
            let mut byte = 0;
            for start in starts {
                result.push_str(&text[byte..start]);
                result.push_str(replacement);
                byte = start + m;
            }
            result.push_str(&text[byte..]);
            return Some(result);
        }
    }

    let regex = compile(query)?;
    let mut spans = Vec::new();
    let mut matched_bytes = 0usize;
    for found in regex.find_iter(text) {
        let Ok(found) = found else { break };
        matched_bytes += found.end() - found.start();
        spans.push((found.start(), found.end()));
    }
    if spans.is_empty() {
        return Some(text.to_string());
    }
    let exact_len = text.len() - matched_bytes + spans.len() * replacement.len();
    let mut result = String::with_capacity(exact_len);
    let mut byte = 0;
    for (start, end) in spans {
        result.push_str(&text[byte..start]);
        result.push_str(replacement);
        byte = end;
    }
    result.push_str(&text[byte..]);
    Some(result)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn query(pattern: &str, is_regex: bool) -> Query {
        Query {
            pattern: pattern.to_string(),
            is_regex,
            case_sensitive: false,
            whole_word: false,
        }
    }

    #[test]
    fn offsets_count_scalars() {
        assert_eq!(
            find("节点😀 a节点", &query("节点", false)),
            Some(vec![0, 2, 5, 7])
        );
        assert_eq!(find("éa x éa", &query("éa", false)), Some(vec![0, 2, 5, 7]));
    }

    #[test]
    fn plain_text_is_not_a_pattern() {
        assert_eq!(find("a.b axb", &query("a.b", false)), Some(vec![0, 3]));
        assert_eq!(find("a.b axb", &query("a.b", true)), Some(vec![0, 3, 4, 7]));
    }

    #[test]
    fn options_narrow_the_matches() {
        let mut q = query("port", false);
        assert_eq!(find("Port port ports", &q), Some(vec![0, 4, 5, 9, 10, 14]));
        q.case_sensitive = true;
        assert_eq!(find("Port port ports", &q), Some(vec![5, 9, 10, 14]));
        q.whole_word = true;
        assert_eq!(find("Port port ports", &q), Some(vec![5, 9]));
    }

    #[test]
    fn anchors_work_per_line() {
        assert_eq!(find("a\nb\n", &query("^.", true)), Some(vec![0, 1, 2, 3]));
        assert_eq!(find("ab\ncd", &query("$", true)), Some(vec![2, 2, 5, 5]));
    }

    #[test]
    fn lookaround_and_backreferences_are_supported() {
        assert_eq!(
            find("port: 80", &query(r"(?<=port: )\d+", true)),
            Some(vec![6, 8])
        );
        assert_eq!(
            find("aa ab bb", &query(r"(\w)\1", true)),
            Some(vec![0, 2, 6, 8])
        );
    }

    #[test]
    fn an_invalid_pattern_is_reported() {
        assert_eq!(find("abc", &query("(", true)), None);
        assert_eq!(replace_all("abc", &query("(", true), "x"), None);
    }

    #[test]
    fn a_runaway_pattern_ends_instead_of_hanging() {
        let text = format!("{}b", "a".repeat(40));
        let started = std::time::Instant::now();
        let found = find(&text, &query(r"(?=(a+)+$)x|(a+)+\1$", true));
        assert!(found.is_some());
        assert!(started.elapsed().as_secs() < 2);
    }

    #[test]
    fn replacement_is_literal() {
        assert_eq!(
            replace_all("port: 80", &query(r"(\d+)", true), "$1x"),
            Some("port: $1x".to_string())
        );
    }

    #[test]
    fn test_plain_replace_all_case_sensitive_and_insensitive() {
        let mut q = query("port", false);
        assert_eq!(
            replace_all("Port port ports", &q, "proxy"),
            Some("proxy proxy proxys".to_string())
        );
        q.case_sensitive = true;
        assert_eq!(
            replace_all("Port port ports", &q, "proxy"),
            Some("Port proxy proxys".to_string())
        );
        assert_eq!(
            replace_all("no matches here", &q, "proxy"),
            Some("no matches here".to_string())
        );
    }

    #[test]
    fn test_boundary_search() {
        let q = query(":80", false);
        assert_eq!(find("host:80", &q), Some(vec![4, 7]));
        assert_eq!(find("host:", &q), Some(vec![]));
        assert_eq!(find(":", &q), Some(vec![]));
        assert_eq!(find("", &q), Some(vec![]));
    }

    #[test]
    fn multi_chunk_rope_search_and_replace_match_str_reference() {
        let mut doc = String::new();
        for i in 0..1200 {
            doc.push_str(&format!(
                "  - name: 🇭🇰 香港节点 {:04} Port:{}\n    server: hk{}.example.com\n    port: {}\n",
                i,
                if i % 50 == 0 { 80 } else { 443 },
                i,
                if i % 50 == 0 { 80 } else { 8080 }
            ));
        }
        let rope = Rope::from_str(&doc);
        assert!(rope.chunks().count() > 20);

        let queries = [
            Query {
                pattern: "port".into(),
                is_regex: false,
                case_sensitive: false,
                whole_word: false,
            },
            Query {
                pattern: "port".into(),
                is_regex: false,
                case_sensitive: true,
                whole_word: true,
            },
            Query {
                pattern: "香港节点 0500".into(),
                is_regex: false,
                case_sensitive: true,
                whole_word: false,
            },
            Query {
                pattern: r"Port:80\n\s+server: hk\d+".into(),
                is_regex: true,
                case_sensitive: true,
                whole_word: false,
            },
        ];

        for q in &queries {
            assert_eq!(find_in_slice(rope.slice(..), q), find(&doc, q));
        }

        let first_chunk_len = rope.chunks().next().unwrap().len();
        let mut b_start = first_chunk_len - 5;
        while !doc.is_char_boundary(b_start) {
            b_start -= 1;
        }
        let mut b_end = first_chunk_len + 6;
        while !doc.is_char_boundary(b_end) {
            b_end += 1;
        }
        let boundary_pat = doc[b_start..b_end].to_string();
        for cs in [true, false] {
            let bq = Query {
                pattern: boundary_pat.clone(),
                is_regex: false,
                case_sensitive: cs,
                whole_word: false,
            };
            assert_eq!(find_in_slice(rope.slice(..), &bq), find(&doc, &bq));
        }

        let rep_query = Query {
            pattern: "80".into(),
            is_regex: false,
            case_sensitive: true,
            whole_word: true,
        };
        let expected = replace_all(&doc, &rep_query, "53").unwrap();
        let edit = replace_all_in_rope(&rope, &rep_query, "53").unwrap();
        let mut updated = rope.clone();
        updated.remove(edit.start_scalar as usize..edit.end_scalar as usize);
        updated.insert(edit.start_scalar as usize, &edit.replacement);
        assert_eq!(updated.to_string(), expected);
        assert!(replace_all_in_rope(&rope, &rep_query, "80").is_none());
    }

    #[test]
    #[ignore]
    fn bench_rope_search_and_snapshot() {
        let mut doc = String::with_capacity(8 * 1024 * 1024);
        for i in 0..100_000 {
            doc.push_str(&format!(
                "  - DOMAIN-SUFFIX,service-{:06}.example.com,🇯🇵 日本节点\n",
                i
            ));
        }
        let buf = super::super::Buffer::from_normalized(&doc);
        let snap = buf.snapshot();
        let q_plain = Query {
            pattern: "service-099999".into(),
            is_regex: false,
            case_sensitive: false,
            whole_word: false,
        };

        let t0 = std::time::Instant::now();
        for _ in 0..20 {
            let full = buf.text();
            let res = find(&full, &q_plain).unwrap();
            assert_eq!(res.len(), 2);
        }
        let legacy_ms = t0.elapsed().as_secs_f64() * 1000.0 / 20.0;

        let t1 = std::time::Instant::now();
        for _ in 0..20 {
            let res = find_in_slice(buf.rope().slice(..), &q_plain).unwrap();
            assert_eq!(res.len(), 2);
        }
        let rope_ms = t1.elapsed().as_secs_f64() * 1000.0 / 20.0;

        let edited = super::super::Buffer::from_normalized(&doc);
        edited.remove(500_000, 500_006);
        edited.insert(500_000, "999999");

        let t2 = std::time::Instant::now();
        for _ in 0..100 {
            assert!(!super::super::ropes_equal(&edited.rope(), &snap));
        }
        let eq_us = t2.elapsed().as_secs_f64() * 1_000_000.0 / 100.0;

        println!(
            "Doc size: {:.2} MB ({} lines)\nLegacy full-text copy+find: {:.2} ms\nRope zero-copy find:        {:.2} ms\nSame-length dirty check:    {:.2} us",
            doc.len() as f64 / (1024.0 * 1024.0),
            buf.len_lines(),
            legacy_ms,
            rope_ms,
            eq_us
        );
    }
}
