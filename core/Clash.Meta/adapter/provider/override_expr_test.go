package provider

import (
	"math"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/metacubex/mihomo/common/structure"
)

func mustOverrideExprs(t *testing.T, sources ...string) []OverrideExpr {
	t.Helper()
	expressions := make([]OverrideExpr, len(sources))
	for idx, source := range sources {
		expr, err := NewOverrideExpr(source)
		require.NoError(t, err)
		expressions[idx] = expr
	}
	return expressions
}

func TestOverrideExprDecode(t *testing.T) {
	decoder := structure.NewDecoder(structure.Option{TagName: "provider", WeaklyTypedInput: true})
	var schema overrideSchema
	err := decoder.Decode(map[string]any{
		"override-expr": []any{
			".udp = true",
			`.name = "prefix-" + .name`,
		},
	}, &schema)
	require.NoError(t, err)
	require.Len(t, schema.OverrideExpr, 2)
	require.Equal(t, ".udp = true", schema.OverrideExpr[0].String())
	require.Equal(t, `.name = "prefix-" + .name`, schema.OverrideExpr[1].String())
}

func TestOverrideExprTextRoundTrip(t *testing.T) {
	const source = `  .name = "prefix-" + .name  # keep formatting`
	var expr OverrideExpr
	require.NoError(t, expr.UnmarshalText([]byte(source)))

	text, err := expr.MarshalText()
	require.NoError(t, err)
	require.Equal(t, source, string(text))
	require.Equal(t, source, expr.String())
}

func TestOverrideExprAssignments(t *testing.T) {
	mapping := map[string]any{
		"name":     "node",
		"existing": "keep",
		"ports":    []any{80, 443},
		"tags":     []any{"base"},
		"weights":  map[string]any{"a": 1, "b": 2},
	}
	override := overrideSchema{OverrideExpr: mustOverrideExprs(t,
		`.udp = true`,
		`.skip-cert-verify = false`,
		`.plugin-opts.mode = "tls"`,
		`.ports[1] = 8443`,
		`.slots[2].enabled = true`,
		`.weights[] += 1`,
		`."quoted.field" = "quoted"`,
		`.tags += ["edge"]`,
		`.missing = .missing // "fallback"`,
		`.existing = .existing // "ignored"`,
	)}

	require.NoError(t, override.Apply(mapping))
	require.Equal(t, true, mapping["udp"])
	require.Equal(t, false, mapping["skip-cert-verify"])
	require.Equal(t, map[string]any{"mode": "tls"}, mapping["plugin-opts"])
	require.Equal(t, []any{80, 8443}, mapping["ports"])
	require.Equal(t, []any{nil, nil, map[string]any{"enabled": true}}, mapping["slots"])
	require.Equal(t, map[string]any{"a": 2, "b": 3}, mapping["weights"])
	require.Equal(t, "quoted", mapping["quoted.field"])
	require.Equal(t, []any{"base", "edge"}, mapping["tags"])
	require.Equal(t, "fallback", mapping["missing"])
	require.Equal(t, "keep", mapping["existing"])
}

func TestOverrideExprUpdateFunctionsAndConditionalPath(t *testing.T) {
	mapping := map[string]any{
		"name":   "HK-01",
		"score":  3,
		"labels": []any{"edge", "premium"},
	}
	override := overrideSchema{OverrideExpr: mustOverrideExprs(t,
		`.name |= sub("^HK-(.*)$"; "Hong Kong $1")`,
		`.name = "[Provider] " + .name`,
		`.score *= 2`,
		`.labels[] |= upcase`,
		`.enabled = (.score >= 6 and has("name"))`,
		`(select(.score > 5) | .tier) = "fast" | (select(.score <= 5) | .tier) = "slow"`,
	)}

	require.NoError(t, override.Apply(mapping))
	require.Equal(t, "[Provider] Hong Kong 01", mapping["name"])
	require.Equal(t, 6, mapping["score"])
	require.Equal(t, []any{"EDGE", "PREMIUM"}, mapping["labels"])
	require.Equal(t, true, mapping["enabled"])
	require.Equal(t, "fast", mapping["tier"])
}

func TestOverrideExprCollectionsAndDelete(t *testing.T) {
	mapping := map[string]any{
		"password": "secret",
		"obsolete": true,
		"ports":    []any{80, 443, 8080},
		"options": map[string]any{
			"tls": map[string]any{"sni": "example.com"},
		},
		"servers": []any{
			map[string]any{"host": "a", "secret": "x"},
			map[string]any{"host": "b", "secret": "y"},
		},
	}
	override := overrideSchema{OverrideExpr: mustOverrideExprs(t,
		`.options *= {"tls": {"enabled": true}, "retries": 3}`,
		`.ports -= [80, 8080]`,
		`del(.password, .obsolete)`,
		`del(.servers[].secret)`,
	)}

	require.NoError(t, override.Apply(mapping))
	require.NotContains(t, mapping, "password")
	require.NotContains(t, mapping, "obsolete")
	require.Equal(t, []any{443}, mapping["ports"])
	require.Equal(t, map[string]any{
		"tls":     map[string]any{"sni": "example.com", "enabled": true},
		"retries": 3,
	}, mapping["options"])
	require.Equal(t, []any{
		map[string]any{"host": "a"},
		map[string]any{"host": "b"},
	}, mapping["servers"])
}

func TestOverrideExprDeleteUsesOriginalArrayIndexes(t *testing.T) {
	mapping := map[string]any{"values": []any{0, 1, 2, 3}}
	override := overrideSchema{OverrideExpr: mustOverrideExprs(t, `del(.values[0], .values[2])`)}

	require.NoError(t, override.Apply(mapping))
	require.Equal(t, []any{1, 3}, mapping["values"])
}

func TestOverrideExprRunsAfterStructuredOverride(t *testing.T) {
	udp := true
	override := overrideSchema{
		UDP:          &udp,
		OverrideExpr: mustOverrideExprs(t, `.udp = false`),
	}
	mapping := map[string]any{"name": "node"}

	require.NoError(t, override.Apply(mapping))
	require.Equal(t, false, mapping["udp"])
}

func TestOverrideExprYQCompatibility(t *testing.T) {
	mapping := map[string]any{
		"name":         "edge-01",
		"key.with.dot": "quoted",
		"items":        []any{"first", "last"},
		"csv":          "a,b,c",
		"number":       "42",
		"options":      map[string]any{"b": 2, "a": 1},
	}
	override := overrideSchema{OverrideExpr: mustOverrideExprs(t,
		`.quoted = .["key.with.dot"]`,
		`.quoted-again = ."key.with.dot"`,
		`.last = .items[-1]`,
		`.csv |= split(",") | .csv |= join("-")`,
		`.number |= tonumber`,
		`.name-length = .name | .name-length |= length`,
		`.option-keys = .options | .option-keys |= keys`,
		`.fallback = false // "default"`,
		`.calculated = (5 + 3) * 2`,
		`. = . * {"root-merged": true}`,
	)}

	require.NoError(t, override.Apply(mapping))
	require.Equal(t, "quoted", mapping["quoted"])
	require.Equal(t, "quoted", mapping["quoted-again"])
	require.Equal(t, "last", mapping["last"])
	require.Equal(t, "a-b-c", mapping["csv"])
	require.Equal(t, 42, mapping["number"])
	require.Equal(t, 7, mapping["name-length"])
	require.Equal(t, []any{"a", "b"}, mapping["option-keys"])
	require.Equal(t, "default", mapping["fallback"])
	require.Equal(t, 16, mapping["calculated"])
	require.Equal(t, true, mapping["root-merged"])
}

func TestOverrideExprOperatorsAndFunctions(t *testing.T) {
	testCases := []struct {
		name     string
		input    any
		expr     string
		expected any
	}{
		{name: "negative literal", input: 4, expr: `.value = -4`, expected: -4},
		{name: "not", input: true, expr: `.value |= not`, expected: false},
		{name: "numeric subtraction", input: 5, expr: `.value -= 2`, expected: 3},
		{name: "division", input: 5, expr: `.value = .value / 2`, expected: 2.5},
		{name: "string division", input: "a,b", expr: `.value = .value / ","`, expected: []any{"a", "b"}},
		{name: "empty string division", input: "", expr: `.value = .value / ","`, expected: []any{}},
		{name: "split null can default", input: nil, expr: `.value = (.value | split(",")) // "fallback"`, expected: "fallback"},
		{name: "modulo", input: 5, expr: `.value = .value % 2`, expected: 1},
		{name: "float modulo", input: 5.5, expr: `.value = .value % 2`, expected: 1.5},
		{name: "repeat", input: "ab", expr: `.value *= 2`, expected: "abab"},
		{name: "repeat with integer first", input: "ab", expr: `.value = 2 * .value`, expected: "abab"},
		{name: "multiply null identity", input: []any{1}, expr: `.value = .value * null`, expected: []any{1}},
		{name: "multiply arrays replaces left", input: []any{1}, expr: `.value = .value * [2]`, expected: []any{2}},
		{name: "sub replaces all", input: "a-b-c", expr: `.value |= sub("-", "_")`, expected: "a_b_c"},
		{name: "test", input: "edge-01", expr: `.value |= test("^edge-")`, expected: true},
		{name: "contains string", input: "edge-01", expr: `.value |= contains("ge-")`, expected: true},
		{name: "contains array", input: []any{1, 2}, expr: `.value |= contains([2])`, expected: true},
		{name: "contains scalar", input: 2, expr: `.value |= contains(2)`, expected: true},
		{name: "string plus number", input: "port-", expr: `.value = .value + 443`, expected: "port-443"},
		{name: "array plus scalar", input: []any{1}, expr: `.value = .value + 2`, expected: []any{1, 2}},
		{name: "null subtraction", input: nil, expr: `.value = .value - 2`, expected: 2},
		{name: "shallow map addition", input: map[string]any{"a": 1, "nested": map[string]any{"left": true}}, expr: `.value += {"b": 2, "nested": {"right": true}}`, expected: map[string]any{"a": 1, "b": 2, "nested": map[string]any{"right": true}}},
		{name: "not equal", input: 2, expr: `.value = .value != 1`, expected: true},
		{name: "numeric types are distinct", input: 1, expr: `.value = .value == 1.0`, expected: false},
		{name: "scalar equality uses text", input: 1, expr: `.value = .value == "1"`, expected: true},
		{name: "boolean equality uses text", input: true, expr: `.value = .value == "true"`, expected: true},
		{name: "less than", input: 1, expr: `.value = .value < 2`, expected: true},
		{name: "boolean or", input: false, expr: `.value = (.value or true)`, expected: true},
		{name: "trim downcase", input: "  EDGE  ", expr: `.value |= trim | .value |= downcase`, expected: "edge"},
		{name: "comma function arguments", input: "a-b", expr: `.value |= sub("-", "_")`, expected: "a_b"},
		{name: "to string", input: []any{1, 2}, expr: `.value |= tostring`, expected: "- 1\n- 2"},
		{name: "map to string", input: map[string]any{"a": 1}, expr: `.value |= tostring`, expected: "a: 1"},
		{name: "type", input: []any{1}, expr: `.value |= type`, expected: "!!seq"},
		{name: "map type", input: map[string]any{"a": 1}, expr: `.value |= type`, expected: "!!map"},
		{name: "array keys", input: []any{"a", "b"}, expr: `.value |= keys`, expected: []any{0, 1}},
		{name: "has array index", input: []any{"a"}, expr: `.value |= has(0)`, expected: true},
		{name: "has negative array index", input: []any{"a"}, expr: `.value |= has(-1)`, expected: true},
		{name: "contains keeps scalar tags distinct", input: 1, expr: `.value |= contains(1.0)`, expected: false},
		{name: "test accepts global option", input: "edge-edge", expr: `.value |= test("edge", "g")`, expected: true},
		{name: "null alternative", input: nil, expr: `.value = ~ // "fallback"`, expected: "fallback"},
	}

	for _, testCase := range testCases {
		t.Run(testCase.name, func(t *testing.T) {
			mapping := map[string]any{"value": testCase.input}
			override := overrideSchema{OverrideExpr: mustOverrideExprs(t, testCase.expr)}
			require.NoError(t, override.Apply(mapping))
			require.Equal(t, testCase.expected, mapping["value"])
		})
	}
}

func TestOverrideExprDivisionAndModuloByZero(t *testing.T) {
	mapping := map[string]any{"one": 1, "zero": 0, "float": 1.5}
	override := overrideSchema{OverrideExpr: mustOverrideExprs(t,
		`.infinite = .one / .zero`,
		`.not-a-number = .zero / .zero`,
		`.float-modulo = .float % .zero`,
	)}

	require.NoError(t, override.Apply(mapping))
	require.True(t, math.IsInf(mapping["infinite"].(float64), 1))
	require.True(t, math.IsNaN(mapping["not-a-number"].(float64)))
	require.True(t, math.IsNaN(mapping["float-modulo"].(float64)))
}

func TestOverrideExprSelectAndPipelines(t *testing.T) {
	mapping := map[string]any{
		"name":  " edge ",
		"score": 8,
		"servers": []any{
			map[string]any{"name": "first", "enabled": true},
			map[string]any{"name": "second", "enabled": false},
		},
	}
	override := overrideSchema{OverrideExpr: mustOverrideExprs(t,
		`.name = (.name | trim | upcase)`,
		`(select(.score > 5) | .tier) = "fast"`,
		`(select(.score < 0) | .ignored) = true`,
		`(.servers[] | select(.enabled) | .name) |= upcase`,
	)}

	require.NoError(t, override.Apply(mapping))
	require.Equal(t, "EDGE", mapping["name"])
	require.Equal(t, "fast", mapping["tier"])
	require.NotContains(t, mapping, "ignored")
	require.Equal(t, []any{
		map[string]any{"name": "FIRST", "enabled": true},
		map[string]any{"name": "second", "enabled": false},
	}, mapping["servers"])

	lowScore := map[string]any{"score": 3}
	conditional := overrideSchema{OverrideExpr: mustOverrideExprs(t,
		`(select(.score > 5) | .tier) = "fast" | (select(.score <= 5) | .tier) = "slow"`,
	)}
	require.NoError(t, conditional.Apply(lowScore))
	require.Equal(t, "slow", lowScore["tier"])
}

func TestOverrideExprYQBehaviorDetails(t *testing.T) {
	testCases := []struct {
		name     string
		input    any
		expr     string
		expected any
	}{
		{name: "scalar path produces null", input: "text", expr: `.result = .value.missing`, expected: nil},
		{name: "scalar path can default", input: "text", expr: `.result = .value.missing // "fallback"`, expected: "fallback"},
		{name: "recursive contains array", input: []any{map[string]any{"a": 1, "b": 2}}, expr: `.result = (.value | contains([{"a": 1}]))`, expected: true},
		{name: "recursive contains map", input: map[string]any{"a": map[string]any{"b": 1, "c": 2}}, expr: `.result = (.value | contains({"a": {"b": 1}}))`, expected: true},
		{name: "float type", input: 1.0, expr: `.result = (.value | type)`, expected: "!!float"},
		{name: "number length", input: 1234, expr: `.result = (.value | length)`, expected: 4},
		{name: "bool length", input: false, expr: `.result = (.value | length)`, expected: 5},
		{name: "null length", input: nil, expr: `.result = (.value | length)`, expected: 0},
		{name: "array length", input: []any{1, 2}, expr: `.result = (.value | length)`, expected: 2},
		{name: "map length", input: map[string]any{"a": 1, "b": 2}, expr: `.result = (.value | length)`, expected: 2},
		{name: "unicode byte length", input: "a界", expr: `.result = (.value | length)`, expected: 4},
		{name: "join skips collections", input: []any{"a", nil, []any{1}, map[string]any{"a": 1}, 2}, expr: `.result = (.value | join("-"))`, expected: "a----2"},
		{name: "has rejects float index", input: []any{"a"}, expr: `.result = (.value | has(0.5))`, expected: false},
		{name: "decimal leading zero", input: "010", expr: `.result = (.value | tonumber)`, expected: 10},
		{name: "octal", input: "0o10", expr: `.result = (.value | tonumber)`, expected: 8},
		{name: "hexadecimal", input: "0x10", expr: `.result = (.value | tonumber)`, expected: 16},
		{name: "float", input: "1.5", expr: `.result = (.value | tonumber)`, expected: 1.5},
		{name: "unknown string escape stays literal", input: nil, expr: `.result = "a\tb\u754c"`, expected: `a\tb\u754c`},
		{name: "array equality", input: []any{1, 2}, expr: `.result = (.value == [1, 2])`, expected: false},
		{name: "mapping inequality", input: map[string]any{"a": 1}, expr: `.result = (.value != {"a": 1})`, expected: true},
		{name: "null comparison", input: nil, expr: `.result = (.value < false)`, expected: false},
		{name: "null equality comparison", input: nil, expr: `.result = (.value <= null)`, expected: true},
	}

	for _, testCase := range testCases {
		t.Run(testCase.name, func(t *testing.T) {
			mapping := map[string]any{"value": testCase.input}
			override := overrideSchema{OverrideExpr: mustOverrideExprs(t, testCase.expr)}
			require.NoError(t, override.Apply(mapping))
			require.Contains(t, mapping, "result")
			require.Equal(t, testCase.expected, mapping["result"])
		})
	}

}

func TestOverrideExprInterpolationAndCollections(t *testing.T) {
	mapping := map[string]any{
		"name":       "node",
		"type":       "ss",
		"port":       443,
		"options":    map[string]any{"b": 2, "a": 1},
		"mixed":      []any{3, nil, false, 2, true},
		"duplicates": []any{1, 1, "1", "1"},
		"nested":     []any{1, []any{2, []any{3}}},
		"truthy":     []any{nil, false, "value"},
		"all-true":   []any{1, "value", true},
	}
	override := overrideSchema{OverrideExpr: mustOverrideExprs(t,
		`.label = "[\(.type)] \(.name):\(.port)"`,
		`.fallback-label = "\(.missing // \"default\")-\(.name)"`,
		`.first-label = "\((.name, .type))"`,
		`.options-text = "\(.options)"`,
		`.hex = 0x10`,
		`.reversed = (.mixed | reverse)`,
		`.sorted = (.mixed | sort)`,
		`.deduplicated = (.duplicates | unique)`,
		`.flattened = (.nested | flatten)`,
		`.flattened-once = (.nested | flatten(1))`,
		`.has-truthy = (.truthy | any)`,
		`.all-truthy = (.all-true | all)`,
	)}

	require.NoError(t, override.Apply(mapping))
	require.Equal(t, "[ss] node:443", mapping["label"])
	require.Equal(t, "default-node", mapping["fallback-label"])
	require.Equal(t, "node", mapping["first-label"])
	require.Equal(t, "a: 1\nb: 2", mapping["options-text"])
	require.Equal(t, 16, mapping["hex"])
	require.Equal(t, []any{true, 2, false, nil, 3}, mapping["reversed"])
	require.Equal(t, []any{nil, false, true, 2, 3}, mapping["sorted"])
	require.Equal(t, []any{1}, mapping["deduplicated"])
	require.Equal(t, []any{1, 2, 3}, mapping["flattened"])
	require.Equal(t, []any{1, 2, []any{3}}, mapping["flattened-once"])
	require.Equal(t, true, mapping["has-truthy"])
	require.Equal(t, true, mapping["all-truthy"])
}

func TestOverrideExprMultiResultPipelines(t *testing.T) {
	mapping := map[string]any{
		"items": []any{
			map[string]any{"name": "first", "port": 80, "enabled": true},
			map[string]any{"name": "second", "port": 443, "enabled": false},
		},
		"scores":  map[string]any{"a": 1, "b": 2},
		"options": map[string]any{"a": 1, "b": 2},
	}
	override := overrideSchema{OverrideExpr: mustOverrideExprs(t,
		`.names = [.items[].name]`,
		`.enabled-names = [.items[] | select(.enabled) | .name]`,
		`.name-ports = [.items[] | (.name, .port)]`,
		`.incremented-ports = [.items[].port + 1]`,
		`.mapped-names = (.items | map(.name))`,
		`.mapped-union = (.items | map(.name, .port))`,
		`.filtered = (.items | filter(.enabled))`,
		`.mapped-scores = (.scores | map_values(. + 1))`,
		`.selected-scores = (.scores | map_values(select(. > 1)))`,
		`.entries = (.options | to_entries)`,
		`.roundtrip = (.options | to_entries | from_entries)`,
		`.upper-options = (.options | with_entries(.key |= upcase))`,
		`.has-large-port = ([.items[].port] | any_c(. > 100))`,
		`.all-positive = ([.items[].port] | all_c(. > 0))`,
		`.no-matches = [.items[] | select(false)]`,
		`.defaults = [.items[].missing // "default"]`,
	)}

	require.NoError(t, override.Apply(mapping))
	require.Equal(t, []any{"first", "second"}, mapping["names"])
	require.Equal(t, []any{"first"}, mapping["enabled-names"])
	require.Equal(t, []any{"first", "second", 80, 443}, mapping["name-ports"])
	require.Equal(t, []any{81, 444}, mapping["incremented-ports"])
	require.Equal(t, []any{"first", "second"}, mapping["mapped-names"])
	require.Equal(t, []any{"first", "second", 80, 443}, mapping["mapped-union"])
	require.Equal(t, []any{map[string]any{"name": "first", "port": 80, "enabled": true}}, mapping["filtered"])
	require.Equal(t, map[string]any{"a": 2, "b": 3}, mapping["mapped-scores"])
	require.Equal(t, map[string]any{"a": 1, "b": 2}, mapping["selected-scores"])
	require.Equal(t, []any{
		map[string]any{"key": "a", "value": 1},
		map[string]any{"key": "b", "value": 2},
	}, mapping["entries"])
	require.Equal(t, map[string]any{"a": 1, "b": 2}, mapping["roundtrip"])
	require.Equal(t, map[string]any{"A": 1, "B": 2}, mapping["upper-options"])
	require.Equal(t, true, mapping["has-large-port"])
	require.Equal(t, true, mapping["all-positive"])
	require.Equal(t, []any{}, mapping["no-matches"])
	require.Equal(t, []any{"default", "default"}, mapping["defaults"])
}

func TestOverrideExprMappingValuesUseYQStreamSemantics(t *testing.T) {
	mapping := map[string]any{"items": []any{1, 2}}
	override := overrideSchema{OverrideExpr: mustOverrideExprs(t,
		`.result = {"omitted": select(false), "last": (.items[])}`,
	)}

	require.NoError(t, override.Apply(mapping))
	require.Equal(t, map[string]any{"last": 2}, mapping["result"])
}

func TestOverrideExprRequiresMultiResultsToBeCollected(t *testing.T) {
	mapping := map[string]any{"items": []any{1, 2}}
	override := overrideSchema{OverrideExpr: mustOverrideExprs(t, `.result = (.items[])`)}

	err := override.Apply(mapping)
	require.ErrorContains(t, err, "expression produced 2 results")
	require.ErrorContains(t, err, "collect them with [...]")
}

func TestOverrideExprTopLevelFilterPipeline(t *testing.T) {
	mapping := map[string]any{"name": "node", "udp": false}
	override := overrideSchema{OverrideExpr: mustOverrideExprs(t,
		`. | with_entries(.key |= upcase)`,
		`{"name": .NAME, "udp": .UDP, "type": "ss"}`,
	)}

	require.NoError(t, override.Apply(mapping))
	require.Equal(t, map[string]any{"name": "node", "udp": false, "type": "ss"}, mapping)
}

func TestOverrideExprErrors(t *testing.T) {
	t.Run("syntax", func(t *testing.T) {
		decoder := structure.NewDecoder(structure.Option{TagName: "provider", WeaklyTypedInput: true})
		var schema overrideSchema
		err := decoder.Decode(map[string]any{"override-expr": []any{`.udp =`}}, &schema)
		require.ErrorContains(t, err, "override-expr[0]")
		require.ErrorContains(t, err, "expected value")
	})

	t.Run("runtime", func(t *testing.T) {
		override := overrideSchema{OverrideExpr: mustOverrideExprs(t, `.port += [1]`)}
		mapping := map[string]any{"port": 443}
		err := override.Apply(mapping)
		require.ErrorContains(t, err, `override-expr[0] ".port += [1]"`)
		require.ErrorContains(t, err, "operator + cannot be used")
	})

	t.Run("string repeat limit", func(t *testing.T) {
		override := overrideSchema{OverrideExpr: mustOverrideExprs(t, `.value = "x" * 10000001`)}
		err := override.Apply(map[string]any{"value": "x"})
		require.ErrorContains(t, err, "cannot exceed 10 million")
	})
}
