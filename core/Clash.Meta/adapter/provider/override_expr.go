package provider

import (
	"encoding"
	"fmt"
	"math"
	"reflect"
	"regexp"
	"sort"
	"strconv"
	"strings"
	"unicode"

	"github.com/metacubex/mihomo/common/yaml"
)

// OverrideExpr is an update-oriented subset of yq expressions for modifying a single proxy provider mapping.
// Configure it as an ordered string array; each item observes the result of all previous items:
//
//	proxy-providers:
//	  provider-name:
//	    override:
//	      override-expr:
//	        - '.name = "[provider] " + .name'
//	        - '.udp = true'
//	        - '.skip-cert-verify = false'
//	        - '.plugin-opts.mode = "tls"'
//	        - '.alpn[] |= upcase'
//	        - 'del(.password)'
//
// Supported paths:
//   - Root and mapping fields: ., .name, .plugin-opts.mode.
//   - Quoted fields: ."field.with.dots" and .["field.with.dots"].
//   - Array indexes, including negative indexes: .servers[0], .servers[-1].
//   - Array or mapping wildcards: .alpn[] and .servers[].password.
//   - Missing mappings and non-negative array indexes are created on assignment.
//   - Reading through a scalar produces null; updating through one is a no-op.
//
// Supported update statements:
//   - Assignment: =.
//     Its right side uses the root mapping as dot context.
//   - Update assignment: |=.
//     The right side receives the selected old value as its dot context, for example '.name |= upcase'.
//   - Compound assignment: +=, -=, and *=.
//   - Deletion: del(.field), del(.a, .b), and del(.items[].secret).
//     del(.) is rejected because deleting the complete input cannot produce a mapping.
//   - Conditional paths: '(select(.score > 5) | .tier) = "fast"'.
//     A select that is false produces no match, so the assignment is skipped.
//   - Statement pipelines: '.name |= trim | .name |= upcase'.
//     A pipeline used as an assignment value must be parenthesized, for example '.name = (.name | upcase)' or '.name |= (trim | upcase)'.
//     The same rule applies to and/or values.
//   - Multi-result value pipelines.
//     Wildcards, select, and comma unions may produce zero or more results; collect them with brackets, for example '.names = [.servers[] | select(.enabled) | .name]'.
//     An assignment value that still has multiple uncollected results is rejected because a proxy provider override must produce one mapping.
//   - A complete override-expr item may itself be a filter pipeline, for example '. | with_entries(.key |= upcase)'.
//     Its final result must be exactly one mapping.
//
// Supported value expressions:
//   - null (null or ~), booleans, decimal/hex integers, floats, double-quoted strings, arrays, and mappings with double-quoted keys.
//     String escapes follow yq: \n, \", and \\ are decoded; other backslash sequences remain literal.
//     Arrays collect all item results; mapping values omit their key on zero results and keep the last of multiple results.
//   - Path references, parentheses, and negative decimal integer/float literals.
//   - Comma unions, for example '(.name, .port)'.
//     A union after a wildcard follows yq stream ordering: each union branch processes all inputs.
//   - yq string interpolation, for example '"[\(.type)] \(.name)"'.
//     An interpolation expression with multiple results uses its first result.
//   - A # outside a string starts a comment through the end of the expression item.
//   - Arithmetic and collection operators: +, -, *, /, and %.
//     '+' concatenates strings/arrays and shallow-merges mappings.
//     '*' multiplies numbers, repeats strings, replaces arrays, and deep-merges mappings.
//     '/' splits strings when both operands are strings.
//   - Comparisons: ==, !=, <, <=, >, and >=.
//     Equality follows yq scalar-value semantics and does not structurally compare arrays or mappings.
//     Ordered comparisons support numbers, strings, and null.
//   - Boolean/default operators: and, or, and //.
//     Only false and null are falsey.
//
// Supported functions use the current dot value as input:
//   - Collection queries: length, keys, has, contains, and select.
//     String length is measured in UTF-8 bytes.
//     keys supports arrays/mappings; has accepts string mapping keys or positive/negative array indexes.
//   - Array operations: reverse, sort, unique, flatten, any, and all.
//     sort is limited to scalar arrays.
//     flatten accepts an optional non-negative depth.
//     any/all implement their zero-arg forms.
//   - Stream/collection transforms: map, map_values, filter, to_entries, from_entries, with_entries, any_c, and all_c.
//     map/filter/map_values accept arrays or mappings and operate on their values.
//     map/filter return arrays; map_values preserves the input collection shape.
//     to_entries accepts arrays/mappings and produces no result for null; from_entries accepts arrays of entries.
//     from_entries requires string keys because the target configuration is map[string]any.
//     with_entries therefore supports mappings only; any_c/all_c support arrays only.
//   - String checks: test(pattern) and test(pattern, "g").
//   - String transforms: sub, split, join, upcase, downcase, and trim.
//     Like yq, sub replaces every regular-expression match.
//     split produces no result for null; join accepts arrays.
//   - Conversion/introspection: tostring, tonumber, type, and not.
//
// Function arguments use yq-style comma separators.
// A semicolon is also accepted as an argument separator for compatibility with older expressions.
// Ordinary function arguments must not produce multiple results; map/filter-style expression arguments may produce streams.
// For example:
//
//	.name |= sub("^HK-(.*)$", "Hong Kong $1")
//	.tags |= split(",")
//	.options *= {"tls": {"enabled": true}, "retries": 3}
//
// This intentionally does not implement the complete yq language.
// Variables, reduce, dynamic paths, recursive descent, document streams, file/environment access, custom tags, and yq CLI flags are not supported.
// Evaluation uses values instead of yq's mutable node references.
// Out-of-range reads do not extend source arrays, and flatten/map_values in a right-side filter do not mutate their source path; use |= to request an update.
// A right-side expression with no result leaves its target untouched instead of auto-creating a null value.
// Mapping streams, keys, and entry transforms use sorted keys because map[string]any does not retain YAML key order.
// Expressions are parsed while overrideSchema is decoded through encoding.TextUnmarshaler, so syntax errors are reported before providers run.
type OverrideExpr struct {
	source     string
	statements []overrideStatement
}

var (
	_ encoding.TextMarshaler   = OverrideExpr{}
	_ encoding.TextUnmarshaler = (*OverrideExpr)(nil)
)

type overrideStatement interface {
	apply(map[string]any) error
}

// NewOverrideExpr parses source into an OverrideExpr.
func NewOverrideExpr(source string) (OverrideExpr, error) {
	tokens, err := lexOverrideExpr(source)
	if err != nil {
		return OverrideExpr{}, err
	}
	p := overrideExprParser{tokens: tokens}
	expr, err := p.parse()
	expr.source = source
	return expr, err
}

// UnmarshalText parses text into e.
func (e *OverrideExpr) UnmarshalText(text []byte) error {
	expr, err := NewOverrideExpr(string(text))
	if err != nil {
		return err
	}
	*e = expr
	return nil
}

// MarshalText returns the original expression text.
func (e OverrideExpr) MarshalText() ([]byte, error) {
	return []byte(e.source), nil
}

// String returns the original expression text.
func (e OverrideExpr) String() string {
	return e.source
}

// Apply applies the expression to mapping.
func (e OverrideExpr) Apply(mapping map[string]any) error {
	for _, statement := range e.statements {
		if err := statement.apply(mapping); err != nil {
			return err
		}
	}
	return nil
}

type overrideTokenKind uint8

const (
	overrideTokenEOF overrideTokenKind = iota
	overrideTokenDot
	overrideTokenIdentifier
	overrideTokenString
	overrideTokenNumber
	overrideTokenLeftParen
	overrideTokenRightParen
	overrideTokenLeftBracket
	overrideTokenRightBracket
	overrideTokenLeftBrace
	overrideTokenRightBrace
	overrideTokenComma
	overrideTokenSemicolon
	overrideTokenColon
	overrideTokenPipe
	overrideTokenAssign
	overrideTokenUpdateAssign
	overrideTokenAddAssign
	overrideTokenSubtractAssign
	overrideTokenMultiplyAssign
	overrideTokenPlus
	overrideTokenMinus
	overrideTokenMultiply
	overrideTokenDivide
	overrideTokenModulo
	overrideTokenAlternative
	overrideTokenEqual
	overrideTokenNotEqual
	overrideTokenLess
	overrideTokenLessEqual
	overrideTokenGreater
	overrideTokenGreaterEqual
)

type overrideToken struct {
	kind overrideTokenKind
	text string
	pos  int
}

func lexOverrideExpr(source string) ([]overrideToken, error) {
	tokens := make([]overrideToken, 0, 16)
	for pos := 0; pos < len(source); {
		ch := source[pos]
		if unicode.IsSpace(rune(ch)) {
			pos++
			continue
		}
		if ch == '#' {
			break
		}

		start := pos
		switch ch {
		case '.':
			tokens = append(tokens, overrideToken{kind: overrideTokenDot, text: ".", pos: pos})
			pos++
		case '(':
			tokens = append(tokens, overrideToken{kind: overrideTokenLeftParen, text: "(", pos: pos})
			pos++
		case ')':
			tokens = append(tokens, overrideToken{kind: overrideTokenRightParen, text: ")", pos: pos})
			pos++
		case '[':
			tokens = append(tokens, overrideToken{kind: overrideTokenLeftBracket, text: "[", pos: pos})
			pos++
		case ']':
			tokens = append(tokens, overrideToken{kind: overrideTokenRightBracket, text: "]", pos: pos})
			pos++
		case '{':
			tokens = append(tokens, overrideToken{kind: overrideTokenLeftBrace, text: "{", pos: pos})
			pos++
		case '}':
			tokens = append(tokens, overrideToken{kind: overrideTokenRightBrace, text: "}", pos: pos})
			pos++
		case ',':
			tokens = append(tokens, overrideToken{kind: overrideTokenComma, text: ",", pos: pos})
			pos++
		case ';':
			tokens = append(tokens, overrideToken{kind: overrideTokenSemicolon, text: ";", pos: pos})
			pos++
		case ':':
			tokens = append(tokens, overrideToken{kind: overrideTokenColon, text: ":", pos: pos})
			pos++
		case '|':
			if pos+1 < len(source) && source[pos+1] == '=' {
				tokens = append(tokens, overrideToken{kind: overrideTokenUpdateAssign, text: "|=", pos: pos})
				pos += 2
			} else {
				tokens = append(tokens, overrideToken{kind: overrideTokenPipe, text: "|", pos: pos})
				pos++
			}
		case '+':
			kind, width := overrideTokenPlus, 1
			if pos+1 < len(source) && source[pos+1] == '=' {
				kind, width = overrideTokenAddAssign, 2
			}
			tokens = append(tokens, overrideToken{kind: kind, text: source[pos : pos+width], pos: pos})
			pos += width
		case '-':
			kind, width := overrideTokenMinus, 1
			if pos+1 < len(source) && source[pos+1] == '=' {
				kind, width = overrideTokenSubtractAssign, 2
			}
			tokens = append(tokens, overrideToken{kind: kind, text: source[pos : pos+width], pos: pos})
			pos += width
		case '*':
			kind, width := overrideTokenMultiply, 1
			if pos+1 < len(source) && source[pos+1] == '=' {
				kind, width = overrideTokenMultiplyAssign, 2
			}
			tokens = append(tokens, overrideToken{kind: kind, text: source[pos : pos+width], pos: pos})
			pos += width
		case '/':
			kind, width := overrideTokenDivide, 1
			if pos+1 < len(source) && source[pos+1] == '/' {
				kind, width = overrideTokenAlternative, 2
			}
			tokens = append(tokens, overrideToken{kind: kind, text: source[pos : pos+width], pos: pos})
			pos += width
		case '%':
			tokens = append(tokens, overrideToken{kind: overrideTokenModulo, text: "%", pos: pos})
			pos++
		case '=':
			kind, width := overrideTokenAssign, 1
			if pos+1 < len(source) && source[pos+1] == '=' {
				kind, width = overrideTokenEqual, 2
			}
			tokens = append(tokens, overrideToken{kind: kind, text: source[pos : pos+width], pos: pos})
			pos += width
		case '!':
			if pos+1 >= len(source) || source[pos+1] != '=' {
				return nil, fmt.Errorf("unexpected %q at column %d", ch, pos+1)
			}
			tokens = append(tokens, overrideToken{kind: overrideTokenNotEqual, text: "!=", pos: pos})
			pos += 2
		case '<', '>':
			kind := overrideTokenLess
			if ch == '>' {
				kind = overrideTokenGreater
			}
			width := 1
			if pos+1 < len(source) && source[pos+1] == '=' {
				width = 2
				if ch == '<' {
					kind = overrideTokenLessEqual
				} else {
					kind = overrideTokenGreaterEqual
				}
			}
			tokens = append(tokens, overrideToken{kind: kind, text: source[pos : pos+width], pos: pos})
			pos += width
		case '"':
			value, next, err := scanOverrideString(source, pos)
			if err != nil {
				return nil, err
			}
			tokens = append(tokens, overrideToken{kind: overrideTokenString, text: value, pos: pos})
			pos = next
		case '~':
			tokens = append(tokens, overrideToken{kind: overrideTokenIdentifier, text: "~", pos: pos})
			pos++
		default:
			switch {
			case ch >= '0' && ch <= '9':
				pos = scanOverrideNumber(source, pos)
				tokens = append(tokens, overrideToken{kind: overrideTokenNumber, text: source[start:pos], pos: start})
			case isOverrideIdentifierStart(rune(ch)):
				pos++
				for pos < len(source) && isOverrideIdentifierPart(rune(source[pos])) {
					pos++
				}
				tokens = append(tokens, overrideToken{kind: overrideTokenIdentifier, text: source[start:pos], pos: start})
			default:
				return nil, fmt.Errorf("unexpected %q at column %d", ch, pos+1)
			}
		}
	}
	tokens = append(tokens, overrideToken{kind: overrideTokenEOF, pos: len(source)})
	return tokens, nil
}

func scanOverrideString(source string, start int) (string, int, error) {
	for pos := start + 1; pos < len(source); pos++ {
		if source[pos] == '\\' {
			pos++
			continue
		}
		if source[pos] != '"' {
			continue
		}
		return source[start+1 : pos], pos + 1, nil
	}
	return "", 0, fmt.Errorf("unterminated string at column %d", start+1)
}

func decodeOverrideString(raw string, column int) (string, error) {
	var builder strings.Builder
	for pos := 0; pos < len(raw); pos++ {
		if raw[pos] != '\\' {
			builder.WriteByte(raw[pos])
			continue
		}
		if pos+1 >= len(raw) {
			return "", fmt.Errorf("invalid string escape at column %d", column+pos)
		}
		pos++
		switch raw[pos] {
		case '"':
			builder.WriteByte('"')
		case 'n':
			builder.WriteByte('\n')
		case '\\':
			builder.WriteByte('\\')
		default:
			builder.WriteByte('\\')
			builder.WriteByte(raw[pos])
		}
	}
	return builder.String(), nil
}

func scanOverrideNumber(source string, pos int) int {
	if pos+2 <= len(source) && source[pos] == '0' && pos+1 < len(source) && (source[pos+1] == 'x' || source[pos+1] == 'X') {
		pos += 2
		for pos < len(source) && (source[pos] >= '0' && source[pos] <= '9' || source[pos] >= 'a' && source[pos] <= 'f' || source[pos] >= 'A' && source[pos] <= 'F') {
			pos++
		}
		return pos
	}
	for pos < len(source) && source[pos] >= '0' && source[pos] <= '9' {
		pos++
	}
	if pos < len(source) && source[pos] == '.' {
		pos++
		for pos < len(source) && source[pos] >= '0' && source[pos] <= '9' {
			pos++
		}
	}
	if pos < len(source) && (source[pos] == 'e' || source[pos] == 'E') {
		pos++
		if pos < len(source) && (source[pos] == '+' || source[pos] == '-') {
			pos++
		}
		for pos < len(source) && source[pos] >= '0' && source[pos] <= '9' {
			pos++
		}
	}
	return pos
}

func isOverrideIdentifierStart(ch rune) bool {
	return ch == '_' || unicode.IsLetter(ch)
}

func isOverrideIdentifierPart(ch rune) bool {
	return ch == '_' || ch == '-' || unicode.IsLetter(ch) || unicode.IsDigit(ch)
}

type overrideExprParser struct {
	tokens []overrideToken
	pos    int
}

func (p *overrideExprParser) parse() (OverrideExpr, error) {
	result := OverrideExpr{}
	if p.peek().kind == overrideTokenEOF {
		return result, fmt.Errorf("expression is empty")
	}
	for {
		statement, err := p.parseStatement()
		if err != nil {
			return OverrideExpr{}, err
		}
		result.statements = append(result.statements, statement)
		if !p.match(overrideTokenPipe) {
			break
		}
		if p.peek().kind == overrideTokenEOF {
			return OverrideExpr{}, p.errorf(p.peek(), "expected expression after pipe")
		}
	}
	if token := p.peek(); token.kind != overrideTokenEOF {
		return OverrideExpr{}, p.errorf(token, "unexpected %q", token.text)
	}
	return result, nil
}

func (p *overrideExprParser) parseStatement() (overrideStatement, error) {
	if p.peekIdentifier("del") {
		p.next()
		if _, err := p.expect(overrideTokenLeftParen, "expected '(' after del"); err != nil {
			return nil, err
		}
		var paths []overridePath
		for {
			path, err := p.parsePath()
			if err != nil {
				return nil, err
			}
			paths = append(paths, path)
			if !p.match(overrideTokenComma) {
				break
			}
		}
		if _, err := p.expect(overrideTokenRightParen, "expected ')' after del arguments"); err != nil {
			return nil, err
		}
		for _, path := range paths {
			if len(path.segments) == 0 {
				return nil, p.errorf(p.peek(), "del(.) cannot be represented by a mapping override")
			}
		}
		return overrideDeleteStatement{paths: paths}, nil
	}
	if !p.startsAssignmentStatement() {
		expression, err := p.parseUnionExpression(true)
		if err != nil {
			return nil, err
		}
		return overrideFilterStatement{expression: expression}, nil
	}

	var (
		path   overridePath
		target *overrideAssignmentTarget
		err    error
	)
	if p.peek().kind == overrideTokenLeftParen {
		target, err = p.parseAssignmentTarget()
	} else {
		path, err = p.parsePath()
	}
	if err != nil {
		return nil, err
	}
	op := p.next()
	switch op.kind {
	case overrideTokenAssign, overrideTokenUpdateAssign, overrideTokenAddAssign,
		overrideTokenSubtractAssign, overrideTokenMultiplyAssign:
	default:
		return nil, p.errorf(op, "expected assignment operator after path")
	}
	value, err := p.parseValueExpression(false)
	if err != nil {
		return nil, err
	}
	return overrideAssignStatement{path: path, target: target, operator: op.kind, value: value}, nil
}

func (p *overrideExprParser) startsAssignmentStatement() bool {
	start := p.pos
	if p.peek().kind == overrideTokenDot {
		_, err := p.parsePath()
		result := err == nil && isOverrideAssignmentToken(p.peek().kind)
		p.pos = start
		return result
	}
	if p.peek().kind != overrideTokenLeftParen {
		return false
	}
	depth := 0
	for pos := start; pos < len(p.tokens); pos++ {
		switch p.tokens[pos].kind {
		case overrideTokenLeftParen:
			depth++
		case overrideTokenRightParen:
			depth--
			if depth == 0 {
				return pos+1 < len(p.tokens) && isOverrideAssignmentToken(p.tokens[pos+1].kind)
			}
		}
	}
	return false
}

func (p *overrideExprParser) parseAssignmentTarget() (*overrideAssignmentTarget, error) {
	if _, err := p.expect(overrideTokenLeftParen, "expected '('"); err != nil {
		return nil, err
	}
	target := &overrideAssignmentTarget{}
	for {
		if p.peekIdentifier("select") {
			p.next()
			if _, err := p.expect(overrideTokenLeftParen, "expected '(' after select"); err != nil {
				return nil, err
			}
			condition, err := p.parseValueExpression(true)
			if err != nil {
				return nil, err
			}
			if _, err := p.expect(overrideTokenRightParen, "expected ')' after select condition"); err != nil {
				return nil, err
			}
			target.stages = append(target.stages, overrideTargetStage{condition: condition})
		} else {
			path, err := p.parsePath()
			if err != nil {
				return nil, err
			}
			target.stages = append(target.stages, overrideTargetStage{path: &path})
		}
		if !p.match(overrideTokenPipe) {
			break
		}
	}
	if _, err := p.expect(overrideTokenRightParen, "expected ')' after assignment path"); err != nil {
		return nil, err
	}
	for _, stage := range target.stages {
		if stage.path != nil {
			return target, nil
		}
	}
	return nil, p.errorf(p.peek(), "conditional assignment must select a path")
}

func (p *overrideExprParser) parsePath() (overridePath, error) {
	if _, err := p.expect(overrideTokenDot, "expected path starting with '.'"); err != nil {
		return overridePath{}, err
	}
	path := overridePath{}
	if token := p.peek(); token.kind == overrideTokenIdentifier || token.kind == overrideTokenString {
		token = p.next()
		key, err := p.pathField(token)
		if err != nil {
			return overridePath{}, err
		}
		path.segments = append(path.segments, overridePathSegment{kind: overridePathField, key: key})
	}
	for {
		switch p.peek().kind {
		case overrideTokenDot:
			p.next()
			token := p.next()
			if token.kind != overrideTokenIdentifier && token.kind != overrideTokenString {
				return overridePath{}, p.errorf(token, "expected field name after '.'")
			}
			key, err := p.pathField(token)
			if err != nil {
				return overridePath{}, err
			}
			path.segments = append(path.segments, overridePathSegment{kind: overridePathField, key: key})
		case overrideTokenLeftBracket:
			p.next()
			if p.match(overrideTokenRightBracket) {
				path.segments = append(path.segments, overridePathSegment{kind: overridePathWildcard})
				continue
			}
			token := p.next()
			switch token.kind {
			case overrideTokenString, overrideTokenIdentifier:
				key, err := p.pathField(token)
				if err != nil {
					return overridePath{}, err
				}
				path.segments = append(path.segments, overridePathSegment{kind: overridePathField, key: key})
			case overrideTokenNumber, overrideTokenMinus:
				text := token.text
				if token.kind == overrideTokenMinus {
					number, err := p.expect(overrideTokenNumber, "expected array index after '-'")
					if err != nil {
						return overridePath{}, err
					}
					text += number.text
				}
				index, err := strconv.Atoi(text)
				if err != nil {
					return overridePath{}, p.errorf(token, "invalid array index %q", text)
				}
				path.segments = append(path.segments, overridePathSegment{kind: overridePathIndex, index: index})
			default:
				return overridePath{}, p.errorf(token, "expected field name or array index")
			}
			if _, err := p.expect(overrideTokenRightBracket, "expected ']' after path index"); err != nil {
				return overridePath{}, err
			}
		default:
			return path, nil
		}
	}
}

func (p *overrideExprParser) pathField(token overrideToken) (string, error) {
	if token.kind == overrideTokenIdentifier {
		return token.text, nil
	}
	value, err := decodeOverrideString(token.text, token.pos+1)
	if err != nil {
		return "", p.errorf(token, "%v", err)
	}
	return value, nil
}

func (p *overrideExprParser) parseValueExpression(allowLowPrecedence bool) (overrideValueExpr, error) {
	var (
		first overrideValueExpr
		err   error
	)
	if expression, ok, updateErr := p.parseValueUpdateExpression(); ok || updateErr != nil {
		first, err = expression, updateErr
	} else if allowLowPrecedence {
		first, err = p.parseOr()
	} else {
		first, err = p.parseAlternative()
	}
	if err != nil {
		return nil, err
	}
	if !allowLowPrecedence {
		return first, nil
	}
	stages := []overrideValueExpr{first}
	for p.peek().kind == overrideTokenPipe {
		p.next()
		stage, ok, err := p.parseValueUpdateExpression()
		if !ok && err == nil {
			stage, err = p.parseOr()
		}
		if err != nil {
			return nil, err
		}
		stages = append(stages, stage)
	}
	if len(stages) == 1 {
		return first, nil
	}
	return overridePipelineExpr{stages: stages}, nil
}

func (p *overrideExprParser) parseValueUpdateExpression() (overrideValueExpr, bool, error) {
	if p.peek().kind != overrideTokenDot {
		return nil, false, nil
	}
	start := p.pos
	path, err := p.parsePath()
	if err != nil || !isOverrideAssignmentToken(p.peek().kind) {
		p.pos = start
		return nil, false, nil
	}
	operator := p.next()
	value, err := p.parseValueExpression(false)
	if err != nil {
		return nil, true, err
	}
	return overrideValueUpdateExpr{path: path, operator: operator.kind, value: value}, true, nil
}

func (p *overrideExprParser) parseUnionExpression(allowLowPrecedence bool) (overrideValueExpr, error) {
	first, err := p.parseValueExpression(allowLowPrecedence)
	if err != nil {
		return nil, err
	}
	values := []overrideValueExpr{first}
	for p.match(overrideTokenComma) {
		value, err := p.parseValueExpression(allowLowPrecedence)
		if err != nil {
			return nil, err
		}
		values = append(values, value)
	}
	if len(values) == 1 {
		return first, nil
	}
	return overrideUnionExpr{values: values}, nil
}

func isOverrideAssignmentToken(kind overrideTokenKind) bool {
	switch kind {
	case overrideTokenAssign, overrideTokenUpdateAssign, overrideTokenAddAssign,
		overrideTokenSubtractAssign, overrideTokenMultiplyAssign:
		return true
	default:
		return false
	}
}

func (p *overrideExprParser) parseOr() (overrideValueExpr, error) {
	left, err := p.parseAnd()
	for err == nil && p.peekIdentifier("or") {
		op := p.next()
		var right overrideValueExpr
		right, err = p.parseAnd()
		left = overrideBinaryExpr{operator: op.text, left: left, right: right}
	}
	return left, err
}

func (p *overrideExprParser) parseAnd() (overrideValueExpr, error) {
	left, err := p.parseAlternative()
	for err == nil && p.peekIdentifier("and") {
		op := p.next()
		var right overrideValueExpr
		right, err = p.parseAlternative()
		left = overrideBinaryExpr{operator: op.text, left: left, right: right}
	}
	return left, err
}

func (p *overrideExprParser) parseAlternative() (overrideValueExpr, error) {
	left, err := p.parseComparison()
	for err == nil && p.match(overrideTokenAlternative) {
		var right overrideValueExpr
		right, err = p.parseComparison()
		left = overrideBinaryExpr{operator: "//", left: left, right: right}
	}
	return left, err
}

func (p *overrideExprParser) parseComparison() (overrideValueExpr, error) {
	left, err := p.parseAdditive()
	for err == nil {
		token := p.peek()
		switch token.kind {
		case overrideTokenEqual, overrideTokenNotEqual, overrideTokenLess, overrideTokenLessEqual, overrideTokenGreater, overrideTokenGreaterEqual:
			p.next()
			var right overrideValueExpr
			right, err = p.parseAdditive()
			left = overrideBinaryExpr{operator: token.text, left: left, right: right}
		default:
			return left, err
		}
	}
	return left, err
}

func (p *overrideExprParser) parseAdditive() (overrideValueExpr, error) {
	left, err := p.parseMultiplicative()
	for err == nil {
		token := p.peek()
		if token.kind != overrideTokenPlus && token.kind != overrideTokenMinus {
			return left, nil
		}
		p.next()
		var right overrideValueExpr
		right, err = p.parseMultiplicative()
		left = overrideBinaryExpr{operator: token.text, left: left, right: right}
	}
	return left, err
}

func (p *overrideExprParser) parseMultiplicative() (overrideValueExpr, error) {
	left, err := p.parseUnary()
	for err == nil {
		token := p.peek()
		if token.kind != overrideTokenMultiply && token.kind != overrideTokenDivide && token.kind != overrideTokenModulo {
			return left, nil
		}
		p.next()
		var right overrideValueExpr
		right, err = p.parseUnary()
		left = overrideBinaryExpr{operator: token.text, left: left, right: right}
	}
	return left, err
}

func (p *overrideExprParser) parseUnary() (overrideValueExpr, error) {
	if p.peek().kind == overrideTokenMinus {
		minus := p.next()
		number := p.next()
		if number.kind != overrideTokenNumber {
			return nil, p.errorf(minus, "unary '-' is only supported for number literals")
		}
		number.text = "-" + number.text
		return p.parseNumber(number)
	}
	return p.parsePrimary()
}

func (p *overrideExprParser) parseNumber(token overrideToken) (overrideValueExpr, error) {
	if strings.ContainsAny(token.text, ".eE") {
		value, err := strconv.ParseFloat(token.text, 64)
		if err != nil {
			return nil, p.errorf(token, "invalid number %q", token.text)
		}
		return overrideLiteralExpr{value: value}, nil
	}
	base := 10
	text := token.text
	if strings.HasPrefix(text, "0x") || strings.HasPrefix(text, "0X") {
		base, text = 16, text[2:]
	}
	value, err := strconv.ParseInt(text, base, 64)
	if err != nil {
		return nil, p.errorf(token, "invalid number %q", token.text)
	}
	return overrideLiteralExpr{value: int(value)}, nil
}

func (p *overrideExprParser) parseString(token overrideToken) (overrideValueExpr, error) {
	parts := make([]overrideStringPart, 0, 1)
	literalStart := 0
	for pos := 0; pos < len(token.text); {
		if token.text[pos] != '\\' || pos+1 >= len(token.text) {
			pos++
			continue
		}
		if token.text[pos+1] == '\\' {
			pos += 2
			continue
		}
		if token.text[pos+1] != '(' {
			pos += 2
			continue
		}
		literal, err := decodeOverrideString(token.text[literalStart:pos], token.pos+1+literalStart)
		if err != nil {
			return nil, err
		}
		if literal != "" {
			parts = append(parts, overrideStringPart{literal: literal})
		}
		expressionStart := pos + 2
		expressionEnd, err := findOverrideInterpolationEnd(token.text, expressionStart)
		if err != nil {
			return nil, p.errorf(token, "%v", err)
		}
		expressionSource := strings.ReplaceAll(token.text[expressionStart:expressionEnd], `\"`, `"`)
		expression, err := parseOverrideValueExpr(expressionSource)
		if err != nil {
			return nil, p.errorf(token, "invalid interpolation: %v", err)
		}
		parts = append(parts, overrideStringPart{expression: expression})
		pos = expressionEnd + 1
		literalStart = pos
	}
	literal, err := decodeOverrideString(token.text[literalStart:], token.pos+1+literalStart)
	if err != nil {
		return nil, err
	}
	if len(parts) == 0 {
		return overrideLiteralExpr{value: literal}, nil
	}
	if literal != "" {
		parts = append(parts, overrideStringPart{literal: literal})
	}
	return overrideStringExpr{parts: parts}, nil
}

func findOverrideInterpolationEnd(raw string, start int) (int, error) {
	depth := 0
	for pos := start; pos < len(raw); pos++ {
		switch raw[pos] {
		case '\\':
			pos++
		case '"':
			for pos++; pos < len(raw); pos++ {
				if raw[pos] == '\\' {
					pos++
					continue
				}
				if raw[pos] == '"' {
					break
				}
			}
		case '(':
			depth++
		case ')':
			if depth == 0 {
				return pos, nil
			}
			depth--
		}
	}
	return 0, fmt.Errorf("unterminated interpolation")
}

func parseOverrideValueExpr(source string) (overrideValueExpr, error) {
	tokens, err := lexOverrideExpr(source)
	if err != nil {
		return nil, err
	}
	p := overrideExprParser{tokens: tokens}
	expression, err := p.parseUnionExpression(true)
	if err != nil {
		return nil, err
	}
	if token := p.peek(); token.kind != overrideTokenEOF {
		return nil, p.errorf(token, "unexpected %q", token.text)
	}
	return expression, nil
}

func (p *overrideExprParser) parsePrimary() (overrideValueExpr, error) {
	token := p.next()
	switch token.kind {
	case overrideTokenDot:
		p.pos--
		path, err := p.parsePath()
		return overridePathExpr{path: path}, err
	case overrideTokenString:
		return p.parseString(token)
	case overrideTokenNumber:
		return p.parseNumber(token)
	case overrideTokenLeftParen:
		value, err := p.parseUnionExpression(true)
		if err != nil {
			return nil, err
		}
		_, err = p.expect(overrideTokenRightParen, "expected ')'")
		return value, err
	case overrideTokenLeftBracket:
		values := make([]overrideValueExpr, 0)
		if p.match(overrideTokenRightBracket) {
			return overrideArrayExpr{values: values}, nil
		}
		for {
			value, err := p.parseValueExpression(true)
			if err != nil {
				return nil, err
			}
			values = append(values, value)
			if !p.match(overrideTokenComma) {
				break
			}
		}
		_, err := p.expect(overrideTokenRightBracket, "expected ']' after array")
		return overrideArrayExpr{values: values}, err
	case overrideTokenLeftBrace:
		entries := make([]overrideMapEntry, 0)
		if p.match(overrideTokenRightBrace) {
			return overrideMapExpr{entries: entries}, nil
		}
		for {
			key := p.next()
			if key.kind != overrideTokenString {
				return nil, p.errorf(key, "expected quoted map key")
			}
			if _, err := p.expect(overrideTokenColon, "expected ':' after map key"); err != nil {
				return nil, err
			}
			keyValue, err := decodeOverrideString(key.text, key.pos+1)
			if err != nil {
				return nil, err
			}
			value, err := p.parseValueExpression(true)
			if err != nil {
				return nil, err
			}
			entries = append(entries, overrideMapEntry{key: keyValue, value: value})
			if !p.match(overrideTokenComma) {
				break
			}
		}
		_, err := p.expect(overrideTokenRightBrace, "expected '}' after map")
		return overrideMapExpr{entries: entries}, err
	case overrideTokenIdentifier:
		switch token.text {
		case "true":
			return overrideLiteralExpr{value: true}, nil
		case "false":
			return overrideLiteralExpr{value: false}, nil
		case "null", "~":
			return overrideLiteralExpr{}, nil
		}
		args := make([]overrideValueExpr, 0)
		if p.match(overrideTokenLeftParen) {
			if !p.match(overrideTokenRightParen) {
				for {
					arg, err := p.parseValueExpression(true)
					if err != nil {
						return nil, err
					}
					args = append(args, arg)
					if !p.match(overrideTokenComma) && !p.match(overrideTokenSemicolon) {
						break
					}
				}
				if _, err := p.expect(overrideTokenRightParen, "expected ')' after function arguments"); err != nil {
					return nil, err
				}
			}
		}
		if !isOverrideFunction(token.text) {
			return nil, p.errorf(token, "unknown function %q", token.text)
		}
		if isOverrideStreamFunction(token.text) {
			return overrideStreamFunctionExpr{name: token.text, args: args}, nil
		}
		return overrideFunctionExpr{name: token.text, args: args}, nil
	default:
		return nil, p.errorf(token, "expected value")
	}
}

func (p *overrideExprParser) peek() overrideToken {
	return p.tokens[p.pos]
}

func (p *overrideExprParser) next() overrideToken {
	token := p.peek()
	if token.kind != overrideTokenEOF {
		p.pos++
	}
	return token
}

func (p *overrideExprParser) match(kind overrideTokenKind) bool {
	if p.peek().kind != kind {
		return false
	}
	p.next()
	return true
}

func (p *overrideExprParser) expect(kind overrideTokenKind, message string) (overrideToken, error) {
	token := p.next()
	if token.kind != kind {
		return overrideToken{}, p.errorf(token, message)
	}
	return token, nil
}

func (p *overrideExprParser) peekIdentifier(value string) bool {
	token := p.peek()
	return token.kind == overrideTokenIdentifier && token.text == value
}

func (p *overrideExprParser) errorf(token overrideToken, format string, args ...any) error {
	return fmt.Errorf("column %d: %s", token.pos+1, fmt.Sprintf(format, args...))
}

type overridePathSegmentKind uint8

const (
	overridePathField overridePathSegmentKind = iota
	overridePathIndex
	overridePathWildcard
)

type overridePathSegment struct {
	kind  overridePathSegmentKind
	key   string
	index int
}

type overridePath struct {
	segments []overridePathSegment
}

type overrideTargetStage struct {
	path      *overridePath
	condition overrideValueExpr
}

type overrideAssignmentTarget struct {
	stages []overrideTargetStage
}

type overrideTargetSelection struct {
	value any
	path  []overridePathSegment
}

func (t overrideAssignmentTarget) resolve(root any) ([]overrideTargetSelection, error) {
	selections := []overrideTargetSelection{{value: root}}
	for _, stage := range t.stages {
		if stage.path != nil {
			next := make([]overrideTargetSelection, 0, len(selections))
			for _, selection := range selections {
				expanded, err := expandOverrideTargetPath(selection, stage.path.segments)
				if err != nil {
					return nil, err
				}
				next = append(next, expanded...)
			}
			selections = next
			continue
		}
		next := selections[:0]
		for _, selection := range selections {
			matches, err := evalOverrideStream(stage.condition, selection.value)
			if err != nil {
				return nil, err
			}
			for _, matched := range matches {
				if overrideTruthy(matched) {
					next = append(next, selection)
					break
				}
			}
		}
		selections = next
	}
	return selections, nil
}

func expandOverrideTargetPath(selection overrideTargetSelection, path []overridePathSegment) ([]overrideTargetSelection, error) {
	if len(path) == 0 {
		return []overrideTargetSelection{selection}, nil
	}
	segment := path[0]
	appendPath := func(segment overridePathSegment) []overridePathSegment {
		result := append([]overridePathSegment{}, selection.path...)
		return append(result, segment)
	}
	switch segment.kind {
	case overridePathField:
		if selection.value == nil {
			return expandOverrideTargetPath(overrideTargetSelection{path: appendPath(segment)}, path[1:])
		}
		mapping, ok := selection.value.(map[string]any)
		if !ok {
			return nil, nil
		}
		return expandOverrideTargetPath(overrideTargetSelection{value: mapping[segment.key], path: appendPath(segment)}, path[1:])
	case overridePathIndex:
		if selection.value == nil {
			return expandOverrideTargetPath(overrideTargetSelection{path: appendPath(segment)}, path[1:])
		}
		array, ok := selection.value.([]any)
		if !ok {
			return nil, nil
		}
		index := segment.index
		if index < 0 {
			index += len(array)
		}
		if index < 0 {
			return nil, nil
		}
		concrete := overridePathSegment{kind: overridePathIndex, index: index}
		var value any
		if index < len(array) {
			value = array[index]
		}
		return expandOverrideTargetPath(overrideTargetSelection{value: value, path: appendPath(concrete)}, path[1:])
	case overridePathWildcard:
		var result []overrideTargetSelection
		switch value := selection.value.(type) {
		case []any:
			for index, item := range value {
				concrete := overridePathSegment{kind: overridePathIndex, index: index}
				expanded, err := expandOverrideTargetPath(overrideTargetSelection{value: item, path: appendPath(concrete)}, path[1:])
				if err != nil {
					return nil, err
				}
				result = append(result, expanded...)
			}
		case map[string]any:
			keys := make([]string, 0, len(value))
			for key := range value {
				keys = append(keys, key)
			}
			sort.Strings(keys)
			for _, key := range keys {
				concrete := overridePathSegment{kind: overridePathField, key: key}
				expanded, err := expandOverrideTargetPath(overrideTargetSelection{value: value[key], path: appendPath(concrete)}, path[1:])
				if err != nil {
					return nil, err
				}
				result = append(result, expanded...)
			}
		}
		return result, nil
	}
	return nil, fmt.Errorf("invalid path")
}

func (p overridePath) String() string {
	var builder strings.Builder
	builder.WriteByte('.')
	for idx, segment := range p.segments {
		switch segment.kind {
		case overridePathField:
			if idx > 0 {
				builder.WriteByte('.')
			}
			builder.WriteString(segment.key)
		case overridePathIndex:
			fmt.Fprintf(&builder, "[%d]", segment.index)
		case overridePathWildcard:
			builder.WriteString("[]")
		}
	}
	return builder.String()
}

type overrideAssignStatement struct {
	path     overridePath
	target   *overrideAssignmentTarget
	operator overrideTokenKind
	value    overrideValueExpr
}

type overrideFilterStatement struct {
	expression overrideValueExpr
}

func (s overrideFilterStatement) apply(mapping map[string]any) error {
	value, err := evalOverrideSingle(s.expression, mapping)
	if err != nil {
		return err
	}
	if isOverrideNoMatch(value) {
		return fmt.Errorf("filter expression produced no result; a mapping is required")
	}
	result, ok := value.(map[string]any)
	if !ok {
		return fmt.Errorf("filter expression must produce a mapping, got %s", overrideType(value))
	}
	replaceOverrideMapping(mapping, result)
	return nil
}

func (s overrideAssignStatement) apply(mapping map[string]any) error {
	root := any(mapping)
	var updater func(any) (any, error)
	switch s.operator {
	case overrideTokenAssign:
		value, err := evalOverrideSingle(s.value, root)
		if err != nil {
			return err
		}
		if isOverrideNoMatch(value) {
			return nil
		}
		updater = func(any) (any, error) { return cloneOverrideValue(value), nil }
	case overrideTokenUpdateAssign:
		updater = func(old any) (any, error) {
			value, err := evalOverrideSingle(s.value, old)
			if err != nil {
				return nil, err
			}
			if isOverrideNoMatch(value) {
				return old, nil
			}
			return value, nil
		}
	default:
		value, err := evalOverrideSingle(s.value, root)
		if err != nil {
			return err
		}
		if isOverrideNoMatch(value) {
			return nil
		}
		operator := map[overrideTokenKind]string{
			overrideTokenAddAssign:      "+",
			overrideTokenSubtractAssign: "-",
			overrideTokenMultiplyAssign: "*",
		}[s.operator]
		updater = func(old any) (any, error) { return evaluateOverrideBinary(operator, old, value) }
	}

	if s.target != nil {
		selections, err := s.target.resolve(root)
		if err != nil {
			return err
		}
		for _, selection := range selections {
			updated, err := updateOverridePath(root, selection.path, updater)
			if err != nil {
				return fmt.Errorf("update selected path: %w", err)
			}
			updatedMap, ok := updated.(map[string]any)
			if !ok {
				return fmt.Errorf("root expression must produce a mapping, got %s", overrideType(updated))
			}
			if len(selection.path) == 0 {
				replaceOverrideMapping(mapping, updatedMap)
			}
		}
		return nil
	}

	updated, err := updateOverridePath(root, s.path.segments, updater)
	if err != nil {
		return fmt.Errorf("update %s: %w", s.path.String(), err)
	}
	updatedMap, ok := updated.(map[string]any)
	if !ok {
		return fmt.Errorf("root expression must produce a mapping, got %s", overrideType(updated))
	}
	if len(s.path.segments) == 0 {
		replaceOverrideMapping(mapping, updatedMap)
	}
	return nil
}

func replaceOverrideMapping(mapping, replacement map[string]any) {
	replacement = cloneOverrideValue(replacement).(map[string]any)
	for key := range mapping {
		delete(mapping, key)
	}
	for key, value := range replacement {
		mapping[key] = value
	}
}

type overrideDeleteStatement struct {
	paths []overridePath
}

func (s overrideDeleteStatement) apply(mapping map[string]any) error {
	paths := make([][]overridePathSegment, len(s.paths))
	for idx := range s.paths {
		paths[idx] = s.paths[idx].segments
	}
	updated, err := deleteOverridePaths(mapping, paths)
	if err != nil {
		return err
	}
	if _, ok := updated.(map[string]any); !ok {
		return fmt.Errorf("root expression must produce a mapping")
	}
	return nil
}

func deleteOverridePaths(node any, paths [][]overridePathSegment) (any, error) {
	switch value := node.(type) {
	case map[string]any:
		for key, child := range value {
			remove := false
			var tails [][]overridePathSegment
			for _, path := range paths {
				if len(path) == 0 {
					continue
				}
				segment := path[0]
				if segment.kind != overridePathWildcard && (segment.kind != overridePathField || segment.key != key) {
					continue
				}
				if len(path) == 1 {
					remove = true
					break
				}
				tails = append(tails, path[1:])
			}
			if remove {
				delete(value, key)
				continue
			}
			if len(tails) == 0 {
				continue
			}
			updated, err := deleteOverridePaths(child, tails)
			if err != nil {
				return nil, err
			}
			value[key] = updated
		}
		return value, nil
	case []any:
		remove := make([]bool, len(value))
		tails := make([][][]overridePathSegment, len(value))
		for _, path := range paths {
			if len(path) == 0 {
				continue
			}
			segment := path[0]
			var indexes []int
			switch segment.kind {
			case overridePathWildcard:
				indexes = make([]int, len(value))
				for idx := range value {
					indexes[idx] = idx
				}
			case overridePathIndex:
				index := segment.index
				if index < 0 {
					index += len(value)
				}
				if index >= 0 && index < len(value) {
					indexes = []int{index}
				}
			default:
				continue
			}
			for _, index := range indexes {
				if len(path) == 1 {
					remove[index] = true
					continue
				}
				tails[index] = append(tails[index], path[1:])
			}
		}
		result := make([]any, 0, len(value))
		for idx, child := range value {
			if remove[idx] {
				continue
			}
			if len(tails[idx]) > 0 {
				updated, err := deleteOverridePaths(child, tails[idx])
				if err != nil {
					return nil, err
				}
				child = updated
			}
			result = append(result, child)
		}
		return result, nil
	default:
		return node, nil
	}
}

func updateOverridePath(node any, path []overridePathSegment, updater func(any) (any, error)) (any, error) {
	if len(path) == 0 {
		return updater(node)
	}
	segment := path[0]
	switch segment.kind {
	case overridePathField:
		if node == nil {
			node = map[string]any{}
		}
		mapping, ok := node.(map[string]any)
		if !ok {
			return node, nil
		}
		value, err := updateOverridePath(mapping[segment.key], path[1:], updater)
		if err != nil {
			return nil, err
		}
		mapping[segment.key] = value
		return mapping, nil
	case overridePathIndex:
		if node == nil {
			node = []any{}
		}
		array, ok := node.([]any)
		if !ok {
			return node, nil
		}
		index := segment.index
		if index < 0 {
			index += len(array)
		}
		if index < 0 {
			return nil, fmt.Errorf("array index %d is out of range", segment.index)
		}
		for len(array) <= index {
			array = append(array, nil)
		}
		value, err := updateOverridePath(array[index], path[1:], updater)
		if err != nil {
			return nil, err
		}
		array[index] = value
		return array, nil
	case overridePathWildcard:
		switch value := node.(type) {
		case []any:
			for idx := range value {
				updated, err := updateOverridePath(value[idx], path[1:], updater)
				if err != nil {
					return nil, err
				}
				value[idx] = updated
			}
			return value, nil
		case map[string]any:
			for key, item := range value {
				updated, err := updateOverridePath(item, path[1:], updater)
				if err != nil {
					return nil, err
				}
				value[key] = updated
			}
			return value, nil
		case nil:
			return node, nil
		default:
			return node, nil
		}
	}
	return nil, fmt.Errorf("invalid path")
}

type overrideValueExpr interface {
	eval(any) (any, error)
}

type overrideStreamValueExpr interface {
	evalAll(any) ([]any, error)
}

type overrideBatchStreamValueExpr interface {
	evalAllInputs([]any) ([]any, error)
}

func evalOverrideStream(expression overrideValueExpr, input any) ([]any, error) {
	if expression, ok := expression.(overrideStreamValueExpr); ok {
		return expression.evalAll(input)
	}
	value, err := expression.eval(input)
	if err != nil {
		return nil, err
	}
	if isOverrideNoMatch(value) {
		return nil, nil
	}
	return []any{value}, nil
}

func evalOverrideSingle(expression overrideValueExpr, input any) (any, error) {
	values, err := evalOverrideStream(expression, input)
	if err != nil {
		return nil, err
	}
	switch len(values) {
	case 0:
		return overrideNoMatch{}, nil
	case 1:
		return values[0], nil
	default:
		return nil, fmt.Errorf("expression produced %d results; collect them with [...]", len(values))
	}
}

func evalOverrideStreamInputs(expression overrideValueExpr, inputs []any) ([]any, error) {
	if expression, ok := expression.(overrideBatchStreamValueExpr); ok {
		return expression.evalAllInputs(inputs)
	}
	results := make([]any, 0, len(inputs))
	for _, input := range inputs {
		values, err := evalOverrideStream(expression, input)
		if err != nil {
			return nil, err
		}
		results = append(results, values...)
	}
	return results, nil
}

type overrideNoMatch struct{}

func isOverrideNoMatch(value any) bool {
	_, ok := value.(overrideNoMatch)
	return ok
}

type overridePipelineExpr struct {
	stages []overrideValueExpr
}

func (e overridePipelineExpr) eval(input any) (any, error) {
	return evalOverrideSingle(e, input)
}

func (e overridePipelineExpr) evalAll(input any) ([]any, error) {
	values := []any{input}
	for _, stage := range e.stages {
		next, err := evalOverrideStreamInputs(stage, values)
		if err != nil {
			return nil, err
		}
		values = next
	}
	return values, nil
}

type overrideUnionExpr struct {
	values []overrideValueExpr
}

func (e overrideUnionExpr) eval(input any) (any, error) {
	return evalOverrideSingle(e, input)
}

func (e overrideUnionExpr) evalAll(input any) ([]any, error) {
	return e.evalAllInputs([]any{input})
}

func (e overrideUnionExpr) evalAllInputs(inputs []any) ([]any, error) {
	results := make([]any, 0, len(e.values))
	for _, value := range e.values {
		items, err := evalOverrideStreamInputs(value, inputs)
		if err != nil {
			return nil, err
		}
		results = append(results, items...)
	}
	return results, nil
}

type overrideLiteralExpr struct{ value any }

func (e overrideLiteralExpr) eval(any) (any, error) { return cloneOverrideValue(e.value), nil }

type overrideStringPart struct {
	literal    string
	expression overrideValueExpr
}

type overrideStringExpr struct {
	parts []overrideStringPart
}

func (e overrideStringExpr) eval(input any) (any, error) {
	var builder strings.Builder
	for _, part := range e.parts {
		if part.expression == nil {
			builder.WriteString(part.literal)
			continue
		}
		values, err := evalOverrideStream(part.expression, input)
		if err != nil {
			return nil, err
		}
		if len(values) == 0 {
			continue
		}
		value := values[0]
		if value, ok := value.(string); ok {
			builder.WriteString(value)
			continue
		}
		if isOverrideScalar(value) {
			if value == nil {
				builder.WriteString("null")
			} else {
				fmt.Fprint(&builder, value)
			}
			continue
		}
		encoded, err := yaml.Marshal(value)
		if err != nil {
			return nil, err
		}
		builder.WriteString(strings.TrimSuffix(string(encoded), "\n"))
	}
	return builder.String(), nil
}

type overridePathExpr struct{ path overridePath }

func (e overridePathExpr) eval(value any) (any, error) {
	return evalOverrideSingle(e, value)
}

func (e overridePathExpr) evalAll(value any) ([]any, error) {
	return lookupOverridePathStream(value, e.path.segments)
}

func lookupOverridePathStream(value any, path []overridePathSegment) ([]any, error) {
	if len(path) == 0 {
		return []any{value}, nil
	}
	segment := path[0]
	switch segment.kind {
	case overridePathField:
		mapping, ok := value.(map[string]any)
		if !ok {
			return []any{nil}, nil
		}
		return lookupOverridePathStream(mapping[segment.key], path[1:])
	case overridePathIndex:
		array, ok := value.([]any)
		if !ok {
			return []any{nil}, nil
		}
		index := segment.index
		if index < 0 {
			index += len(array)
		}
		if index < 0 || index >= len(array) {
			return []any{nil}, nil
		}
		return lookupOverridePathStream(array[index], path[1:])
	case overridePathWildcard:
		results := make([]any, 0)
		switch collection := value.(type) {
		case []any:
			for _, item := range collection {
				selected, err := lookupOverridePathStream(item, path[1:])
				if err != nil {
					return nil, err
				}
				results = append(results, selected...)
			}
		case map[string]any:
			keys := make([]string, 0, len(collection))
			for key := range collection {
				keys = append(keys, key)
			}
			sort.Strings(keys)
			for _, key := range keys {
				selected, err := lookupOverridePathStream(collection[key], path[1:])
				if err != nil {
					return nil, err
				}
				results = append(results, selected...)
			}
		}
		return results, nil
	}
	return nil, fmt.Errorf("invalid path")
}

type overrideArrayExpr struct{ values []overrideValueExpr }

func (e overrideArrayExpr) eval(input any) (any, error) {
	result := make([]any, 0, len(e.values))
	for _, value := range e.values {
		items, err := evalOverrideStream(value, input)
		if err != nil {
			return nil, err
		}
		result = append(result, items...)
	}
	return result, nil
}

type overrideMapEntry struct {
	key   string
	value overrideValueExpr
}

type overrideMapExpr struct{ entries []overrideMapEntry }

func (e overrideMapExpr) eval(input any) (any, error) {
	result := make(map[string]any, len(e.entries))
	for _, entry := range e.entries {
		values, err := evalOverrideStream(entry.value, input)
		if err != nil {
			return nil, err
		}
		if len(values) > 0 {
			result[entry.key] = values[len(values)-1]
		}
	}
	return result, nil
}

type overrideValueUpdateExpr struct {
	path     overridePath
	operator overrideTokenKind
	value    overrideValueExpr
}

func (e overrideValueUpdateExpr) eval(input any) (any, error) {
	root := cloneOverrideValue(input)
	var updater func(any) (any, error)
	switch e.operator {
	case overrideTokenAssign:
		value, err := evalOverrideSingle(e.value, root)
		if err != nil {
			return nil, err
		}
		if isOverrideNoMatch(value) {
			return root, nil
		}
		updater = func(any) (any, error) { return cloneOverrideValue(value), nil }
	case overrideTokenUpdateAssign:
		updater = func(old any) (any, error) {
			value, err := evalOverrideSingle(e.value, old)
			if err != nil {
				return nil, err
			}
			if isOverrideNoMatch(value) {
				return old, nil
			}
			return value, nil
		}
	default:
		value, err := evalOverrideSingle(e.value, root)
		if err != nil {
			return nil, err
		}
		operator := map[overrideTokenKind]string{
			overrideTokenAddAssign:      "+",
			overrideTokenSubtractAssign: "-",
			overrideTokenMultiplyAssign: "*",
		}[e.operator]
		updater = func(old any) (any, error) { return evaluateOverrideBinary(operator, old, value) }
	}
	updated, err := updateOverridePath(root, e.path.segments, updater)
	if err != nil {
		return nil, fmt.Errorf("update %s: %w", e.path.String(), err)
	}
	return updated, nil
}

type overrideBinaryExpr struct {
	operator string
	left     overrideValueExpr
	right    overrideValueExpr
}

func (e overrideBinaryExpr) eval(input any) (any, error) {
	return evalOverrideSingle(e, input)
}

func (e overrideBinaryExpr) evalAll(input any) ([]any, error) {
	leftValues, err := evalOverrideStream(e.left, input)
	if err != nil {
		return nil, err
	}
	if e.operator == "//" {
		results := make([]any, 0, len(leftValues))
		for _, left := range leftValues {
			if overrideTruthy(left) {
				results = append(results, left)
				continue
			}
			rightValues, err := evalOverrideStream(e.right, input)
			if err != nil {
				return nil, err
			}
			results = append(results, rightValues...)
		}
		if len(leftValues) == 0 {
			return evalOverrideStream(e.right, input)
		}
		return results, nil
	}
	needsRight := e.operator != "and" && e.operator != "or"
	if !needsRight {
		for _, left := range leftValues {
			if e.operator == "and" && overrideTruthy(left) || e.operator == "or" && !overrideTruthy(left) {
				needsRight = true
				break
			}
		}
	}
	if !needsRight {
		results := make([]any, len(leftValues))
		for idx, left := range leftValues {
			results[idx] = e.operator == "or" && overrideTruthy(left)
		}
		return results, nil
	}
	rightValues, err := evalOverrideStream(e.right, input)
	if err != nil {
		return nil, err
	}
	results := make([]any, 0, len(leftValues)*len(rightValues))
	for _, left := range leftValues {
		if e.operator == "and" && !overrideTruthy(left) {
			results = append(results, false)
			continue
		}
		if e.operator == "or" && overrideTruthy(left) {
			results = append(results, true)
			continue
		}
		for _, right := range rightValues {
			value, err := evaluateOverrideBinary(e.operator, left, right)
			if err != nil {
				return nil, err
			}
			results = append(results, value)
		}
	}
	return results, nil
}

type overrideFunctionExpr struct {
	name string
	args []overrideValueExpr
}

type overrideStreamFunctionExpr struct {
	name string
	args []overrideValueExpr
}

func (e overrideStreamFunctionExpr) eval(input any) (any, error) {
	return evalOverrideSingle(e, input)
}

func (e overrideStreamFunctionExpr) evalAll(input any) ([]any, error) {
	switch e.name {
	case "map", "filter":
		if len(e.args) == 0 {
			return nil, fmt.Errorf("%s expects an expression", e.name)
		}
		values, err := overrideCollectionValues(input)
		if err != nil {
			return nil, fmt.Errorf("%s: %w", e.name, err)
		}
		result := make([]any, 0, len(values))
		if e.name == "map" {
			for _, expression := range e.args {
				items, err := evalOverrideStreamInputs(expression, values)
				if err != nil {
					return nil, err
				}
				result = append(result, items...)
			}
			return []any{result}, nil
		}
		for _, value := range values {
			items, err := evalOverrideExpressionList(e.args, value)
			if err != nil {
				return nil, err
			}
			for _, item := range items {
				if overrideTruthy(item) {
					result = append(result, cloneOverrideValue(value))
					break
				}
			}
		}
		return []any{result}, nil
	case "map_values":
		if len(e.args) == 0 {
			return nil, fmt.Errorf("map_values expects an expression")
		}
		switch value := input.(type) {
		case []any:
			result := cloneOverrideValue(value).([]any)
			for idx := range result {
				items, err := evalOverrideExpressionList(e.args, result[idx])
				if err != nil {
					return nil, err
				}
				if len(items) > 0 {
					result[idx] = cloneOverrideValue(items[0])
				}
			}
			return []any{result}, nil
		case map[string]any:
			result := cloneOverrideValue(value).(map[string]any)
			for key, item := range result {
				items, err := evalOverrideExpressionList(e.args, item)
				if err != nil {
					return nil, err
				}
				if len(items) > 0 {
					result[key] = cloneOverrideValue(items[0])
				}
			}
			return []any{result}, nil
		default:
			return nil, fmt.Errorf("map_values only supports arrays and mappings, got %s", overrideType(input))
		}
	case "to_entries":
		if len(e.args) != 0 {
			return nil, fmt.Errorf("to_entries expects no arguments")
		}
		value, err := toOverrideEntries(input)
		if err != nil {
			return nil, err
		}
		if value == nil {
			return nil, nil
		}
		return []any{value}, nil
	case "from_entries":
		if len(e.args) != 0 {
			return nil, fmt.Errorf("from_entries expects no arguments")
		}
		value, err := fromOverrideEntries(input)
		if err != nil {
			return nil, err
		}
		return []any{value}, nil
	case "with_entries":
		if len(e.args) == 0 {
			return nil, fmt.Errorf("with_entries expects an expression")
		}
		if _, ok := input.(map[string]any); !ok {
			return nil, fmt.Errorf("with_entries only supports mappings, got %s", overrideType(input))
		}
		entries, err := toOverrideEntries(input)
		if err != nil {
			return nil, err
		}
		if entries == nil {
			return nil, nil
		}
		transformed := make([]any, 0, len(entries))
		for _, entry := range entries {
			items, err := evalOverrideExpressionList(e.args, entry)
			if err != nil {
				return nil, err
			}
			transformed = append(transformed, items...)
		}
		value, err := fromOverrideEntries(transformed)
		if err != nil {
			return nil, err
		}
		return []any{value}, nil
	case "any_c", "all_c":
		if len(e.args) == 0 {
			return nil, fmt.Errorf("%s expects a condition", e.name)
		}
		values, ok := input.([]any)
		if !ok {
			return nil, fmt.Errorf("%s only supports arrays, got %s", e.name, overrideType(input))
		}
		result := e.name == "all_c"
		for _, value := range values {
			items, err := evalOverrideExpressionList(e.args, value)
			if err != nil {
				return nil, err
			}
			if len(items) == 0 {
				continue
			}
			matched := overrideTruthy(items[0])
			if e.name == "any_c" && matched {
				return []any{true}, nil
			}
			if e.name == "all_c" && !matched {
				return []any{false}, nil
			}
		}
		return []any{result}, nil
	}
	return nil, fmt.Errorf("unsupported stream function %q", e.name)
}

func evalOverrideExpressionList(expressions []overrideValueExpr, input any) ([]any, error) {
	results := make([]any, 0, len(expressions))
	for _, expression := range expressions {
		values, err := evalOverrideStream(expression, input)
		if err != nil {
			return nil, err
		}
		results = append(results, values...)
	}
	return results, nil
}

func overrideCollectionValues(input any) ([]any, error) {
	switch value := input.(type) {
	case []any:
		return value, nil
	case map[string]any:
		keys := make([]string, 0, len(value))
		for key := range value {
			keys = append(keys, key)
		}
		sort.Strings(keys)
		result := make([]any, len(keys))
		for idx, key := range keys {
			result[idx] = value[key]
		}
		return result, nil
	default:
		return nil, fmt.Errorf("expected array or mapping, got %s", overrideType(input))
	}
}

func toOverrideEntries(input any) ([]any, error) {
	switch value := input.(type) {
	case nil:
		return nil, nil
	case []any:
		result := make([]any, len(value))
		for idx, item := range value {
			result[idx] = map[string]any{"key": idx, "value": cloneOverrideValue(item)}
		}
		return result, nil
	case map[string]any:
		keys := make([]string, 0, len(value))
		for key := range value {
			keys = append(keys, key)
		}
		sort.Strings(keys)
		result := make([]any, len(keys))
		for idx, key := range keys {
			result[idx] = map[string]any{"key": key, "value": cloneOverrideValue(value[key])}
		}
		return result, nil
	default:
		return nil, fmt.Errorf("%s has no keys", overrideType(input))
	}
}

func fromOverrideEntries(input any) (map[string]any, error) {
	entries, ok := input.([]any)
	if !ok {
		return nil, fmt.Errorf("from_entries only supports arrays")
	}
	result := make(map[string]any, len(entries))
	for idx, item := range entries {
		entry, ok := item.(map[string]any)
		if !ok {
			return nil, fmt.Errorf("entry %d must be a mapping", idx)
		}
		key, exists := entry["key"]
		if !exists {
			return nil, fmt.Errorf("entry %d has no key", idx)
		}
		value, exists := entry["value"]
		if !exists {
			return nil, fmt.Errorf("entry %d has no value", idx)
		}
		keyString, ok := key.(string)
		if !ok {
			return nil, fmt.Errorf("entry %d key must be a string in override-expr", idx)
		}
		result[keyString] = cloneOverrideValue(value)
	}
	return result, nil
}

func isOverrideFunction(name string) bool {
	switch name {
	case "length", "type", "keys", "has", "contains", "select",
		"sub", "test", "split", "join", "upcase", "downcase", "trim",
		"tostring", "tonumber", "not", "reverse", "sort", "unique", "flatten",
		"any", "all", "map", "map_values", "filter", "to_entries",
		"from_entries", "with_entries", "any_c", "all_c":
		return true
	default:
		return false
	}
}

func isOverrideStreamFunction(name string) bool {
	switch name {
	case "map", "map_values", "filter", "to_entries", "from_entries",
		"with_entries", "any_c", "all_c":
		return true
	default:
		return false
	}
}

func (e overrideFunctionExpr) eval(input any) (any, error) {
	if isOverrideNoMatch(input) {
		return input, nil
	}
	args := make([]any, len(e.args))
	for idx, arg := range e.args {
		value, err := arg.eval(input)
		if err != nil {
			return nil, err
		}
		args[idx] = value
	}
	argCount := func(want ...int) error {
		for _, count := range want {
			if len(args) == count {
				return nil
			}
		}
		return fmt.Errorf("%s expects %v arguments, got %d", e.name, want, len(args))
	}
	stringArg := func(index int) (string, error) {
		value, ok := args[index].(string)
		if !ok {
			return "", fmt.Errorf("%s argument %d must be a string", e.name, index+1)
		}
		return value, nil
	}

	switch e.name {
	case "select":
		if err := argCount(1); err != nil {
			return nil, err
		}
		if isOverrideNoMatch(args[0]) || !overrideTruthy(args[0]) {
			return overrideNoMatch{}, nil
		}
		return input, nil
	case "not":
		if err := argCount(0); err != nil {
			return nil, err
		}
		return !overrideTruthy(input), nil
	case "reverse":
		if err := argCount(0); err != nil {
			return nil, err
		}
		values, ok := input.([]any)
		if !ok {
			return nil, fmt.Errorf("reverse only supports arrays, got %s", overrideType(input))
		}
		result := cloneOverrideValue(values).([]any)
		for left, right := 0, len(result)-1; left < right; left, right = left+1, right-1 {
			result[left], result[right] = result[right], result[left]
		}
		return result, nil
	case "sort":
		if err := argCount(0); err != nil {
			return nil, err
		}
		values, ok := input.([]any)
		if !ok {
			return nil, fmt.Errorf("sort only supports arrays in override-expr, got %s", overrideType(input))
		}
		result := cloneOverrideValue(values).([]any)
		var sortErr error
		sort.SliceStable(result, func(left, right int) bool {
			comparison, err := compareOverrideSortValues(result[left], result[right])
			if err != nil && sortErr == nil {
				sortErr = err
			}
			return comparison < 0
		})
		if sortErr != nil {
			return nil, sortErr
		}
		return result, nil
	case "unique":
		if err := argCount(0); err != nil {
			return nil, err
		}
		values, ok := input.([]any)
		if !ok {
			return nil, fmt.Errorf("unique only supports arrays, got %s", overrideType(input))
		}
		result := make([]any, 0, len(values))
		seen := make(map[string]struct{}, len(values))
		for _, value := range values {
			key, err := overrideUniqueKey(value)
			if err != nil {
				return nil, err
			}
			if _, exists := seen[key]; exists {
				continue
			}
			seen[key] = struct{}{}
			result = append(result, cloneOverrideValue(value))
		}
		return result, nil
	case "flatten":
		if err := argCount(0, 1); err != nil {
			return nil, err
		}
		values, ok := input.([]any)
		if !ok {
			return nil, fmt.Errorf("flatten only supports arrays, got %s", overrideType(input))
		}
		depth := -1
		if len(args) == 1 {
			number, integer, ok := overrideNumber(args[0])
			if !ok || !integer || number < 0 {
				return nil, fmt.Errorf("flatten depth must be a non-negative integer")
			}
			depth = int(number)
		}
		return flattenOverrideArray(values, depth), nil
	case "any", "all":
		if err := argCount(0); err != nil {
			return nil, err
		}
		values, ok := input.([]any)
		if !ok {
			return nil, fmt.Errorf("%s only supports arrays, got %s", e.name, overrideType(input))
		}
		result := e.name == "all"
		for _, value := range values {
			if e.name == "any" && overrideTruthy(value) {
				return true, nil
			}
			if e.name == "all" && !overrideTruthy(value) {
				return false, nil
			}
		}
		return result, nil
	case "length":
		if err := argCount(0); err != nil {
			return nil, err
		}
		switch value := input.(type) {
		case nil:
			return 0, nil
		case string:
			return len(value), nil
		case []any:
			return len(value), nil
		case map[string]any:
			return len(value), nil
		default:
			if _, _, ok := overrideNumber(input); ok {
				return len(fmt.Sprint(input)), nil
			}
			if _, ok := input.(bool); ok {
				return len(fmt.Sprint(input)), nil
			}
			return nil, fmt.Errorf("length cannot be used with %s", overrideType(input))
		}
	case "type":
		if err := argCount(0); err != nil {
			return nil, err
		}
		return overrideType(input), nil
	case "keys":
		if err := argCount(0); err != nil {
			return nil, err
		}
		switch value := input.(type) {
		case map[string]any:
			keys := make([]string, 0, len(value))
			for key := range value {
				keys = append(keys, key)
			}
			sort.Strings(keys)
			result := make([]any, len(keys))
			for idx, key := range keys {
				result[idx] = key
			}
			return result, nil
		case []any:
			result := make([]any, len(value))
			for idx := range value {
				result[idx] = idx
			}
			return result, nil
		default:
			return nil, fmt.Errorf("%s cannot be used with %s", e.name, overrideType(input))
		}
	case "has":
		if err := argCount(1); err != nil {
			return nil, err
		}
		switch value := input.(type) {
		case map[string]any:
			key, err := stringArg(0)
			if err != nil {
				return nil, err
			}
			_, ok := value[key]
			return ok, nil
		case []any:
			number, integer, ok := overrideNumber(args[0])
			if !ok || !integer {
				return false, nil
			}
			index := int(number)
			if index < 0 {
				index += len(value)
			}
			return index >= 0 && index < len(value), nil
		default:
			return false, nil
		}
	case "contains":
		if err := argCount(1); err != nil {
			return nil, err
		}
		switch value := input.(type) {
		case string:
			needle, err := stringArg(0)
			return err == nil && strings.Contains(value, needle), err
		case []any:
			if _, ok := args[0].([]any); !ok {
				return nil, fmt.Errorf("%s cannot check contained in !!seq", overrideType(args[0]))
			}
			return overrideContains(value, args[0]), nil
		case map[string]any:
			if _, ok := args[0].(map[string]any); !ok {
				return nil, fmt.Errorf("%s cannot check contained in !!map", overrideType(args[0]))
			}
			return overrideContains(value, args[0]), nil
		default:
			if !isOverrideScalar(args[0]) {
				return nil, fmt.Errorf("%s cannot check contained in %s", overrideType(args[0]), overrideType(input))
			}
			if overrideType(input) != overrideType(args[0]) {
				return false, nil
			}
			return overrideEqual(input, args[0]), nil
		}
	case "sub", "test":
		if e.name == "test" {
			if err := argCount(1, 2); err != nil {
				return nil, err
			}
			if len(args) == 2 {
				options, err := stringArg(1)
				if err != nil {
					return nil, err
				}
				if strings.Trim(options, "g") != "" {
					return nil, fmt.Errorf("unsupported test options %q", options)
				}
			}
		} else if err := argCount(2); err != nil {
			return nil, err
		}
		value, ok := input.(string)
		if !ok {
			return nil, fmt.Errorf("%s requires string input", e.name)
		}
		pattern, err := stringArg(0)
		if err != nil {
			return nil, err
		}
		re, err := regexp.Compile(pattern)
		if err != nil {
			return nil, fmt.Errorf("invalid regular expression: %w", err)
		}
		if e.name == "test" {
			return re.MatchString(value), nil
		}
		replacement, err := stringArg(1)
		if err != nil {
			return nil, err
		}
		return re.ReplaceAllString(value, replacement), nil
	case "split":
		if err := argCount(1); err != nil {
			return nil, err
		}
		if input == nil {
			return overrideNoMatch{}, nil
		}
		value, ok := input.(string)
		if !ok {
			return nil, fmt.Errorf("split requires string input")
		}
		separator, err := stringArg(0)
		if err != nil {
			return nil, err
		}
		parts := strings.Split(value, separator)
		result := make([]any, len(parts))
		for idx := range parts {
			result[idx] = parts[idx]
		}
		return result, nil
	case "join":
		if err := argCount(1); err != nil {
			return nil, err
		}
		values, ok := input.([]any)
		if !ok {
			return nil, fmt.Errorf("join requires array input")
		}
		separator, err := stringArg(0)
		if err != nil {
			return nil, err
		}
		parts := make([]string, len(values))
		for idx, value := range values {
			switch value := value.(type) {
			case nil, []any, map[string]any:
				parts[idx] = ""
			case string:
				parts[idx] = value
			default:
				parts[idx] = fmt.Sprint(value)
			}
		}
		return strings.Join(parts, separator), nil
	case "upcase", "downcase", "trim":
		if err := argCount(0); err != nil {
			return nil, err
		}
		value, ok := input.(string)
		if !ok {
			return nil, fmt.Errorf("%s requires string input", e.name)
		}
		switch e.name {
		case "upcase":
			return strings.ToUpper(value), nil
		case "downcase":
			return strings.ToLower(value), nil
		default:
			return strings.TrimSpace(value), nil
		}
	case "tostring":
		if err := argCount(0); err != nil {
			return nil, err
		}
		if value, ok := input.(string); ok {
			return value, nil
		}
		encoded, err := yaml.Marshal(input)
		if err != nil {
			return nil, err
		}
		return strings.TrimSuffix(string(encoded), "\n"), nil
	case "tonumber":
		if err := argCount(0); err != nil {
			return nil, err
		}
		if _, _, ok := overrideNumber(input); ok {
			return input, nil
		}
		value, ok := input.(string)
		if !ok {
			return nil, fmt.Errorf("tonumber requires string or number input")
		}
		base := 10
		integerValue := value
		if strings.HasPrefix(value, "0x") || strings.HasPrefix(value, "0X") {
			base, integerValue = 16, value[2:]
		} else if strings.HasPrefix(value, "0o") {
			base, integerValue = 8, value[2:]
		} else if strings.HasPrefix(value, "0b") || strings.HasPrefix(value, "0B") {
			return nil, fmt.Errorf("cannot convert %q to number", value)
		}
		if integer, err := strconv.ParseInt(integerValue, base, 64); err == nil {
			return int(integer), nil
		}
		number, err := strconv.ParseFloat(value, 64)
		if err != nil {
			return nil, fmt.Errorf("cannot convert %q to number", value)
		}
		return number, nil
	}
	return nil, fmt.Errorf("unsupported function %q", e.name)
}

func evaluateOverrideBinary(operator string, left, right any) (any, error) {
	switch operator {
	case "and":
		return overrideTruthy(left) && overrideTruthy(right), nil
	case "or":
		return overrideTruthy(left) || overrideTruthy(right), nil
	case "//":
		if overrideTruthy(left) {
			return left, nil
		}
		return right, nil
	case "==":
		return overrideYQEqual(left, right), nil
	case "!=":
		return !overrideYQEqual(left, right), nil
	case "<", "<=", ">", ">=":
		if !isOverrideScalar(left) || !isOverrideScalar(right) {
			return nil, fmt.Errorf("cannot compare %s and %s", overrideType(left), overrideType(right))
		}
		if left == nil || right == nil {
			bothNull := left == nil && right == nil
			return bothNull && (operator == "<=" || operator == ">="), nil
		}
		comparison, err := compareOverrideValues(left, right)
		if err != nil {
			return nil, err
		}
		switch operator {
		case "<":
			return comparison < 0, nil
		case "<=":
			return comparison <= 0, nil
		case ">":
			return comparison > 0, nil
		default:
			return comparison >= 0, nil
		}
	case "+":
		if left == nil {
			return cloneOverrideValue(right), nil
		}
		if leftString, ok := left.(string); ok {
			if right == nil {
				return leftString, nil
			}
			if !isOverrideScalar(right) {
				return nil, fmt.Errorf("cannot add string and %s", overrideType(right))
			}
			return leftString + fmt.Sprint(right), nil
		}
		if leftArray, ok := left.([]any); ok {
			result := append([]any{}, leftArray...)
			if right == nil {
				return result, nil
			}
			if rightArray, ok := right.([]any); ok {
				return append(result, cloneOverrideValue(rightArray).([]any)...), nil
			}
			return append(result, cloneOverrideValue(right)), nil
		}
		if leftMap, ok := left.(map[string]any); ok {
			rightMap, ok := right.(map[string]any)
			if !ok {
				return nil, fmt.Errorf("cannot add mapping and %s", overrideType(right))
			}
			result := cloneOverrideValue(leftMap).(map[string]any)
			for key, value := range rightMap {
				result[key] = cloneOverrideValue(value)
			}
			return result, nil
		}
		if rightString, ok := right.(string); ok && isOverrideScalar(left) {
			return fmt.Sprint(left) + rightString, nil
		}
		return evaluateOverrideNumbers(operator, left, right)
	case "-":
		if left == nil {
			return cloneOverrideValue(right), nil
		}
		if leftArray, ok := left.([]any); ok {
			rightArray, ok := right.([]any)
			if !ok {
				return nil, fmt.Errorf("%s cannot be subtracted from !!seq", overrideType(right))
			}
			result := make([]any, 0, len(leftArray))
			for _, item := range leftArray {
				remove := false
				for _, candidate := range rightArray {
					if overrideEqual(item, candidate) {
						remove = true
						break
					}
				}
				if !remove {
					result = append(result, item)
				}
			}
			return result, nil
		}
		return evaluateOverrideNumbers(operator, left, right)
	case "*":
		if right == nil {
			return cloneOverrideValue(left), nil
		}
		if left == nil {
			switch right.(type) {
			case []any, map[string]any:
				return cloneOverrideValue(right), nil
			}
		}
		if leftMap, ok := left.(map[string]any); ok {
			rightMap, ok := right.(map[string]any)
			if !ok {
				return nil, fmt.Errorf("cannot multiply mapping and %s", overrideType(right))
			}
			return mergeOverrideMaps(leftMap, rightMap), nil
		}
		if _, ok := left.([]any); ok {
			if rightArray, ok := right.([]any); ok {
				return cloneOverrideValue(rightArray), nil
			}
		}
		if value, ok := left.(string); ok {
			count, integer, numeric := overrideNumber(right)
			if !numeric || !integer || count < 0 {
				return nil, fmt.Errorf("string multiplier must be a non-negative integer")
			}
			if count > 10000000 {
				return nil, fmt.Errorf("string multiplier cannot exceed 10 million")
			}
			return strings.Repeat(value, int(count)), nil
		}
		if value, ok := right.(string); ok {
			count, integer, numeric := overrideNumber(left)
			if !numeric || !integer || count < 0 {
				return nil, fmt.Errorf("string multiplier must be a non-negative integer")
			}
			if count > 10000000 {
				return nil, fmt.Errorf("string multiplier cannot exceed 10 million")
			}
			return strings.Repeat(value, int(count)), nil
		}
		return evaluateOverrideNumbers(operator, left, right)
	case "/":
		if leftString, ok := left.(string); ok {
			rightString, ok := right.(string)
			if !ok {
				return nil, fmt.Errorf("operator / cannot be used with !!str and %s", overrideType(right))
			}
			if leftString == "" {
				return []any{}, nil
			}
			parts := strings.Split(leftString, rightString)
			result := make([]any, len(parts))
			for idx := range parts {
				result[idx] = parts[idx]
			}
			return result, nil
		}
		return evaluateOverrideNumbers(operator, left, right)
	case "%":
		return evaluateOverrideNumbers(operator, left, right)
	}
	return nil, fmt.Errorf("unsupported operator %q", operator)
}

func evaluateOverrideNumbers(operator string, left, right any) (any, error) {
	leftNumber, leftInteger, leftOK := overrideNumber(left)
	rightNumber, rightInteger, rightOK := overrideNumber(right)
	if !leftOK || !rightOK {
		return nil, fmt.Errorf("operator %s cannot be used with %s and %s", operator, overrideType(left), overrideType(right))
	}
	switch operator {
	case "+":
		if leftInteger && rightInteger {
			return int(leftNumber) + int(rightNumber), nil
		}
		return leftNumber + rightNumber, nil
	case "-":
		if leftInteger && rightInteger {
			return int(leftNumber) - int(rightNumber), nil
		}
		return leftNumber - rightNumber, nil
	case "*":
		if leftInteger && rightInteger {
			return int(leftNumber) * int(rightNumber), nil
		}
		return leftNumber * rightNumber, nil
	case "/":
		return leftNumber / rightNumber, nil
	case "%":
		if leftInteger && rightInteger {
			if rightNumber == 0 {
				return nil, fmt.Errorf("cannot modulo by zero")
			}
			return int(leftNumber) % int(rightNumber), nil
		}
		return math.Mod(leftNumber, rightNumber), nil
	}
	return nil, fmt.Errorf("unsupported numeric operator %q", operator)
}

func compareOverrideValues(left, right any) (int, error) {
	if leftNumber, _, ok := overrideNumber(left); ok {
		rightNumber, _, ok := overrideNumber(right)
		if !ok {
			return 0, fmt.Errorf("cannot compare number and %s", overrideType(right))
		}
		switch {
		case leftNumber < rightNumber:
			return -1, nil
		case leftNumber > rightNumber:
			return 1, nil
		default:
			return 0, nil
		}
	}
	leftString, leftOK := left.(string)
	rightString, rightOK := right.(string)
	if leftOK && rightOK {
		return strings.Compare(leftString, rightString), nil
	}
	return 0, fmt.Errorf("cannot compare %s and %s", overrideType(left), overrideType(right))
}

func compareOverrideSortValues(left, right any) (int, error) {
	rank := func(value any) int {
		switch value.(type) {
		case nil:
			return 0
		case bool:
			return 1
		case string:
			return 3
		case []any, map[string]any:
			return 4
		default:
			if _, _, ok := overrideNumber(value); ok {
				return 2
			}
			return 4
		}
	}
	leftRank, rightRank := rank(left), rank(right)
	if leftRank != rightRank {
		if leftRank < rightRank {
			return -1, nil
		}
		return 1, nil
	}
	switch leftRank {
	case 0:
		return 0, nil
	case 1:
		leftBool, rightBool := left.(bool), right.(bool)
		if leftBool == rightBool {
			return 0, nil
		}
		if !leftBool {
			return -1, nil
		}
		return 1, nil
	case 2, 3:
		return compareOverrideValues(left, right)
	default:
		return 0, fmt.Errorf("sort only supports scalar array values in override-expr")
	}
}

func flattenOverrideArray(values []any, depth int) []any {
	result := make([]any, 0, len(values))
	for _, value := range values {
		children, ok := value.([]any)
		if !ok || depth == 0 {
			result = append(result, cloneOverrideValue(value))
			continue
		}
		nextDepth := depth
		if nextDepth > 0 {
			nextDepth--
		}
		result = append(result, flattenOverrideArray(children, nextDepth)...)
	}
	return result
}

func overrideUniqueKey(value any) (string, error) {
	if isOverrideScalar(value) {
		if value == nil {
			return "null", nil
		}
		return fmt.Sprint(value), nil
	}
	encoded, err := yaml.Marshal(value)
	return string(encoded), err
}

func overrideNumber(value any) (float64, bool, bool) {
	switch number := value.(type) {
	case int:
		return float64(number), true, true
	case int8:
		return float64(number), true, true
	case int16:
		return float64(number), true, true
	case int32:
		return float64(number), true, true
	case int64:
		return float64(number), true, true
	case uint:
		return float64(number), true, true
	case uint8:
		return float64(number), true, true
	case uint16:
		return float64(number), true, true
	case uint32:
		return float64(number), true, true
	case uint64:
		return float64(number), true, true
	case float32:
		return float64(number), false, true
	case float64:
		return number, false, true
	default:
		return 0, false, false
	}
}

func overrideEqual(left, right any) bool {
	if leftNumber, leftInteger, ok := overrideNumber(left); ok {
		rightNumber, rightInteger, ok := overrideNumber(right)
		return ok && leftInteger == rightInteger && leftNumber == rightNumber
	}
	return reflect.DeepEqual(left, right)
}

func overrideYQEqual(left, right any) bool {
	if !isOverrideScalar(left) || !isOverrideScalar(right) {
		return false
	}
	if left == nil || right == nil {
		return left == nil && right == nil
	}
	leftNumber, leftInteger, leftNumeric := overrideNumber(left)
	rightNumber, rightInteger, rightNumeric := overrideNumber(right)
	if leftNumeric && rightNumeric {
		return leftInteger == rightInteger && leftNumber == rightNumber
	}
	return fmt.Sprint(left) == fmt.Sprint(right)
}

func isOverrideScalar(value any) bool {
	switch value.(type) {
	case nil, bool, string:
		return true
	}
	_, _, ok := overrideNumber(value)
	return ok
}

func overrideContains(container, contained any) bool {
	switch container := container.(type) {
	case string:
		value, ok := contained.(string)
		return ok && strings.Contains(container, value)
	case []any:
		values, ok := contained.([]any)
		if !ok {
			values = []any{contained}
		}
		for _, wanted := range values {
			found := false
			for _, candidate := range container {
				if overrideEqual(candidate, wanted) || overrideContains(candidate, wanted) {
					found = true
					break
				}
			}
			if !found {
				return false
			}
		}
		return true
	case map[string]any:
		values, ok := contained.(map[string]any)
		if !ok {
			return false
		}
		for key, wanted := range values {
			candidate, exists := container[key]
			if !exists || (!overrideEqual(candidate, wanted) && !overrideContains(candidate, wanted)) {
				return false
			}
		}
		return true
	default:
		return false
	}
}

func overrideTruthy(value any) bool {
	if value == nil {
		return false
	}
	boolean, ok := value.(bool)
	return !ok || boolean
}

func overrideType(value any) string {
	switch value.(type) {
	case nil:
		return "!!null"
	case bool:
		return "!!bool"
	case string:
		return "!!str"
	case []any:
		return "!!seq"
	case map[string]any:
		return "!!map"
	case float32, float64:
		return "!!float"
	}
	_, integer, numeric := overrideNumber(value)
	if numeric {
		if integer {
			return "!!int"
		}
		return "!!float"
	}
	return fmt.Sprintf("%T", value)
}

func mergeOverrideMaps(left, right map[string]any) map[string]any {
	result := cloneOverrideValue(left).(map[string]any)
	for key, rightValue := range right {
		leftMap, leftOK := result[key].(map[string]any)
		rightMap, rightOK := rightValue.(map[string]any)
		if leftOK && rightOK {
			result[key] = mergeOverrideMaps(leftMap, rightMap)
		} else {
			result[key] = cloneOverrideValue(rightValue)
		}
	}
	return result
}

func cloneOverrideValue(value any) any {
	switch value := value.(type) {
	case map[string]any:
		cloned := make(map[string]any, len(value))
		for key, item := range value {
			cloned[key] = cloneOverrideValue(item)
		}
		return cloned
	case []any:
		cloned := make([]any, len(value))
		for idx, item := range value {
			cloned[idx] = cloneOverrideValue(item)
		}
		return cloned
	default:
		return value
	}
}
