use super::*;
use serde_json::{json, Value as Json};

static NEXT_TOKEN: std::sync::atomic::AtomicU32 = std::sync::atomic::AtomicU32::new(1);

fn token() -> u32 {
    NEXT_TOKEN.fetch_add(1, Ordering::Relaxed)
}

fn run_with(script: &str, config: Json, custom: Option<&str>) -> Result<Json, Failure> {
    evaluate(
        script,
        config.to_string().as_bytes(),
        custom,
        EVALUATE_LIMITS,
        token(),
    )
    .map(|evaluation| serde_json::from_slice(&evaluation.config).unwrap())
}

fn run(script: &str, config: Json) -> Result<Json, Failure> {
    run_with(script, config, None)
}

fn limited(script: &str, limits: Limits) -> Failure {
    evaluate(script, b"{}", None, limits, token())
        .err()
        .expect("script should fail")
}

fn short() -> Limits {
    Limits {
        timeout: Duration::from_millis(200),
        memory: 32 * 1024 * 1024,
        stack: 256 * 1024,
    }
}

#[test]
fn returns_the_object_main_produced() {
    let result = run(
        "function main(config) { config.mode = 'global'; return config }",
        json!({ "mode": "rule" }),
    )
    .unwrap();

    assert_eq!(result["mode"], json!("global"));
}

#[test]
fn accepts_a_lexically_declared_entry() {
    let result = run("const main = (config) => config", json!({ "mode": "rule" })).unwrap();

    assert_eq!(result["mode"], json!("rule"));
}

#[test]
fn renames_rule_and_fills_proxy_providers_before_the_script_runs() {
    let result = run(
        "function main(config) { config.seen = [Array.isArray(config.rules), typeof config.rule, typeof config['proxy-providers']]; return config }",
        json!({ "rule": ["MATCH,DIRECT"], "proxy-providers": null }),
    )
    .unwrap();

    assert_eq!(result["seen"], json!([true, "undefined", "object"]));
    assert_eq!(result["rules"], json!(["MATCH,DIRECT"]));
    assert_eq!(result["proxy-providers"], json!({}));
    assert!(result.get("rule").is_none());
}

#[test]
fn keeps_the_normalized_profile_when_main_returns_no_object() {
    for script in [
        "function main(config) {}",
        "function main(config) { return 1 }",
        "function main(config) { return [config] }",
        "function main(config) { return null }",
        "function main(config) { config.mutated = true; return () => 1 }",
    ] {
        let result = run(script, json!({ "mode": "rule", "rule": [] })).unwrap();

        assert_eq!(
            result,
            json!({ "mode": "rule", "rules": [], "proxy-providers": {} }),
            "{script}"
        );
    }
}

#[test]
fn keeps_script_declarations_out_of_the_global_scope() {
    let result = run(
        "var leaked = 1; function main(config) { config.global = typeof globalThis.leaked; config.local = typeof leaked; return config }",
        json!({}),
    )
    .unwrap();

    assert_eq!(result["global"], json!("undefined"));
    assert_eq!(result["local"], json!("number"));
}

#[test]
fn applies_custom_options_before_main_runs() {
    let script = "const ruleOptionsEnable = { ai: true, ads: true }; function main(config) { config.flags = ruleOptionsEnable; return config }";

    let result = run_with(script, json!({}), Some(r#"{"ads":false,"extra":true}"#)).unwrap();

    assert_eq!(
        result["flags"],
        json!({ "ai": true, "ads": false, "extra": true })
    );
}

#[test]
fn skips_custom_options_when_the_script_declares_none() {
    let result = run_with(
        "function main(config) { config.declared = typeof ruleOptionsEnable; return config }",
        json!({}),
        Some(r#"{"ads":false}"#),
    )
    .unwrap();

    assert_eq!(result["declared"], json!("undefined"));
}

#[test]
fn resolves_a_promise_main_returns() {
    let result = run(
        "async function main(config) { config.mode = await Promise.resolve('global'); return config }",
        json!({ "mode": "rule" }),
    )
    .unwrap();

    assert_eq!(result["mode"], json!("global"));
}

#[test]
fn reports_a_promise_that_never_settles() {
    let failure = run(
        "function main() { return new Promise(() => {}) }",
        json!({}),
    )
    .unwrap_err();

    assert_eq!(failure.kind, ErrorKind::Runtime);
    assert!(
        failure.message.contains("did not settle"),
        "{}",
        failure.message
    );
}

#[test]
fn reports_a_rejected_promise() {
    let failure = run(
        "async function main() { throw new Error('bad profile') }",
        json!({}),
    )
    .unwrap_err();

    assert_eq!(failure.kind, ErrorKind::Runtime);
    assert!(
        failure.message.contains("bad profile"),
        "{}",
        failure.message
    );
}

#[test]
fn reports_a_missing_entry_point() {
    let failure = run("const value = 1", json!({})).unwrap_err();

    assert_eq!(failure.kind, ErrorKind::Runtime);
    assert!(failure.message.contains("main"), "{}", failure.message);
}

#[test]
fn reports_the_message_and_stack_of_a_thrown_error() {
    let failure = run(
        "function main(config) { return config.dns.enable }",
        json!({}),
    )
    .unwrap_err();

    assert_eq!(failure.kind, ErrorKind::Runtime);
    assert!(failure.message.contains("enable"), "{}", failure.message);
    assert!(failure.stack.unwrap_or_default().contains("main"));
}

#[test]
fn reports_a_syntax_error() {
    let failure = run("function main( {", json!({})).unwrap_err();

    assert_eq!(failure.kind, ErrorKind::Syntax);
}

#[test]
fn rejects_a_profile_that_is_not_an_object() {
    let failure = run("function main(config) { return config }", json!([1])).unwrap_err();

    assert_eq!(failure.kind, ErrorKind::InvalidInput);
}

#[test]
fn rejects_malformed_json_inputs() {
    let bad_profile = evaluate(
        "function main(config) { return config }",
        b"{invalid",
        None,
        EVALUATE_LIMITS,
        token(),
    )
    .err()
    .unwrap();
    let bad_custom = evaluate(
        "function main(config) { return config }",
        b"{}",
        Some("{invalid"),
        EVALUATE_LIMITS,
        token(),
    )
    .err()
    .unwrap();

    assert_eq!(bad_profile.kind, ErrorKind::InvalidInput);
    assert_eq!(bad_custom.kind, ErrorKind::InvalidInput);
}

#[test]
fn stops_a_script_that_never_finishes() {
    let started = Instant::now();

    let failure = limited("function main() { while (true) {} }", short());

    assert_eq!(failure.kind, ErrorKind::Timeout);
    assert!(started.elapsed() < Duration::from_secs(5));
}

#[test]
fn stops_a_catastrophic_regular_expression() {
    let failure = limited(
        "function main() { return /(a+)+$/.test('a'.repeat(40) + 'b') }",
        short(),
    );

    assert_eq!(failure.kind, ErrorKind::Timeout);
}

#[test]
fn stops_a_script_that_exhausts_memory() {
    let failure = limited(
        "function main() { const items = []; while (true) items.push('x'.repeat(1024) + items.length) }",
        Limits {
            timeout: Duration::from_secs(10),
            ..short()
        },
    );

    assert_eq!(failure.kind, ErrorKind::OutOfMemory);
}

#[test]
fn stops_unbounded_recursion_without_crashing() {
    let failure = limited(
        "function main() { return dive() } function dive() { return dive() + 1 }",
        short(),
    );

    assert_eq!(failure.kind, ErrorKind::Runtime);
    assert!(failure.message.contains("stack"), "{}", failure.message);
}

#[test]
fn rejects_a_result_that_refers_to_itself() {
    let failure = run(
        "function main(config) { config.self = config; return config }",
        json!({}),
    )
    .unwrap_err();

    assert_eq!(failure.kind, ErrorKind::InvalidOutput);
}

#[test]
fn cancels_a_running_script() {
    let token = token();
    let canceller = std::thread::spawn(move || {
        std::thread::sleep(Duration::from_millis(50));
        cancel(token);
    });
    let started = Instant::now();

    let failure = evaluate(
        "function main() { while (true) {} }",
        b"{}",
        None,
        EVALUATE_LIMITS,
        token,
    )
    .err()
    .unwrap();
    canceller.join().unwrap();

    assert_eq!(failure.kind, ErrorKind::Cancelled);
    assert!(started.elapsed() < Duration::from_secs(5));
}

#[test]
fn ignores_a_cancellation_for_a_finished_script() {
    let token = token();
    evaluate(
        "function main(config) { return config }",
        b"{}",
        None,
        EVALUATE_LIMITS,
        token,
    )
    .unwrap();

    cancel(token);

    assert!(evaluate(
        "function main(config) { return config }",
        b"{}",
        None,
        EVALUATE_LIMITS,
        token
    )
    .is_ok());
}

#[test]
fn captures_console_output() {
    let evaluation = evaluate(
        "function main(config) { console.log('a', 1, { b: 2 }); console.warn('careful'); return config }",
        b"{}",
        None,
        EVALUATE_LIMITS,
        token(),
    )
    .unwrap();

    assert_eq!(
        evaluation.logs,
        vec![
            LogLine {
                level: "log".to_owned(),
                text: "a 1 {\"b\":2}".to_owned()
            },
            LogLine {
                level: "warn".to_owned(),
                text: "careful".to_owned()
            },
        ]
    );
}

#[test]
fn keeps_console_output_when_the_script_fails() {
    let failure = run(
        "function main() { console.log('before'); throw new Error('boom') }",
        json!({}),
    )
    .unwrap_err();

    assert_eq!(failure.logs.len(), 1);
    assert_eq!(failure.logs[0].text, "before");
}

#[test]
fn bounds_console_output() {
    let evaluation = evaluate(
        "function main(config) { for (let i = 0; i < 5000; i++) console.log('line', i); return config }",
        b"{}",
        None,
        EVALUATE_LIMITS,
        token(),
    )
    .unwrap();

    assert_eq!(evaluation.logs.len(), 200);
}

#[test]
fn preserves_key_order_numbers_and_text() {
    let config =
        r#"{"zeta":1,"alpha":{"b":2,"a":1},"port":7890,"ratio":1.5,"name":"🇭🇰 香港 \"01\""}"#;

    let evaluation = evaluate(
        "function main(config) { config.port = config.port + 1.0; config.big = 2 ** 40; return config }",
        config.as_bytes(),
        None,
        EVALUATE_LIMITS,
        token(),
    )
    .unwrap();

    assert_eq!(
        String::from_utf8(evaluation.config).unwrap(),
        r#"{"zeta":1,"alpha":{"b":2,"a":1},"port":7891,"ratio":1.5,"name":"🇭🇰 香港 \"01\"","proxy-providers":{},"big":1099511627776}"#
    );
}

#[test]
fn drops_functions_and_undefined_values_from_the_result() {
    let result = run(
        "function main(config) { config.fn = () => 1; config.missing = undefined; config.list = [undefined, 1]; return config }",
        json!({}),
    )
    .unwrap();

    assert_eq!(result, json!({ "proxy-providers": {}, "list": [null, 1] }));
}

fn fixture() -> (Json, Vec<LogLine>) {
    let script = include_str!("../../tests/fixtures/profile_script.js");
    let config = include_str!("../../tests/fixtures/profile_config.json");
    let evaluation = evaluate(
        script,
        config.as_bytes(),
        Some(r#"{"streaming":false}"#),
        EVALUATE_LIMITS,
        token(),
    )
    .unwrap();
    (
        serde_json::from_slice(&evaluation.config).unwrap(),
        evaluation.logs,
    )
}

#[test]
fn runs_a_profile_override_end_to_end() {
    let (result, logs) = fixture();
    let names: Vec<&str> = result["proxies"]
        .as_array()
        .unwrap()
        .iter()
        .map(|proxy| proxy["name"].as_str().unwrap())
        .collect();

    assert_eq!(names, ["🇭🇰 HK 01", "🇯🇵 JP 01", "🏳️ US 01"]);
    assert_eq!(result["proxy-groups"].as_array().unwrap().len(), 2);
    assert_eq!(result["proxy-groups"][1]["name"], json!("AI"));
    assert_eq!(
        result["rules"],
        json!([
            "DOMAIN-SUFFIX,ai.example,AI",
            "GEOIP,CN,DIRECT",
            "MATCH,Main"
        ])
    );
    assert_eq!(
        result["dns"]["nameserver-policy"]["+.example.com"],
        json!("223.5.5.5")
    );
    assert_eq!(
        result["dns"]["nameserver-policy"]["+.internal"],
        json!("system://")
    );
    assert_eq!(logs.len(), 1);
    assert_eq!(logs[0].text, "enabled services [\"AI\"]");
}

#[test]
fn extracts_script_options() {
    let script = include_str!("../../tests/fixtures/profile_script.js");

    let options: Json = serde_json::from_str(&extract_options(script).unwrap()).unwrap();

    assert_eq!(
        options,
        json!({
            "options": { "ai": true, "streaming": true, "ads": false },
            "icons": { "AI": "ai.png", "Streaming": "tv.png" },
            "policyGroupOptions": ["AI", "Streaming"],
        })
    );
}

#[test]
fn extracts_node_regions() {
    let script = "const Compatible_With_Bettbox = { nodeRegions: { 'US Home': ['美国'] } };";

    let options: Json = serde_json::from_str(&extract_options(script).unwrap()).unwrap();

    assert_eq!(options["nodeRegions"], json!({ "US Home": ["美国"] }));
}

#[test]
fn extracts_empty_options_from_a_plain_script() {
    let options: Json =
        serde_json::from_str(&extract_options("function main(config) { return config }").unwrap())
            .unwrap();

    assert_eq!(
        options,
        json!({ "options": {}, "icons": {}, "policyGroupOptions": [] })
    );
}

#[test]
fn reports_a_script_whose_options_cannot_be_read() {
    assert!(extract_options("function main( {").is_err());
    assert!(extract_options("while (true) {}").is_err());
}

#[test]
fn evaluates_bundled_managed_script() {
    let script = include_str!("../../../../../assets/scripts/managed.js");
    let config = json!({
        "proxies": [
            { "name": "HK 01", "type": "ss", "server": "hk.example.com", "port": 443, "cipher": "aes-128-gcm", "password": "pw" }
        ],
        "rule": ["MATCH,DIRECT"]
    });

    let result = run_with(script, config, Some(r#"{"AI":false}"#)).unwrap();

    assert_eq!(result["proxies"][0]["name"], json!("🇭🇰 HK 01"));
    assert!(result["proxy-groups"].is_array());
    assert!(result["rules"].is_array());
}

#[test]
#[ignore]
fn bench_managed_script() {
    let script = include_str!("../../../../../assets/scripts/managed.js");
    let regions = [
        "🇭🇰 香港",
        "🇯🇵 日本",
        "🇺🇸 美国",
        "🇸🇬 新加坡",
        "🇹🇼 台湾",
        "🇰🇷 韩国",
    ];
    let custom = Some(r#"{"AI":true,"Google":true,"生成地区自动选择组":true}"#);
    for count in [100usize, 500, 1500] {
        let proxies: Vec<Json> = (0..count)
            .map(|i| {
                let name = format!("{} 专线节点 {:03} x1.5", regions[i % regions.len()], i + 1);
                json!({
                    "name": name,
                    "type": "vless",
                    "server": format!("node-{i}.airport-sub.example.com"),
                    "port": 443,
                    "uuid": "11111111-2222-3333-4444-555555555555",
                    "tls": true,
                    "udp": true,
                    "network": "ws",
                    "servername": format!("sni-{i}.cdn.example.com"),
                    "ws-opts": { "path": "/api/v1/stream", "headers": { "Host": format!("sni-{i}.cdn.example.com") } }
                })
            })
            .collect();
        let config = serde_json::to_vec(&json!({
            "proxies": proxies,
            "rule": ["MATCH,DIRECT"],
            "dns": { "enable": true, "nameserver": ["223.5.5.5"] }
        }))
        .unwrap();
        for _ in 0..3 {
            let _ = evaluate(script, &config, custom, EVALUATE_LIMITS, token()).unwrap();
        }
        let rounds = 15;
        let mut samples = Vec::with_capacity(rounds);
        let mut out_len = 0;
        for _ in 0..rounds {
            let started = Instant::now();
            let res = evaluate(script, &config, custom, EVALUATE_LIMITS, token()).unwrap();
            out_len = res.config.len();
            samples.push(started.elapsed());
        }
        samples.sort();
        println!(
            "managed.js @ {count} nodes (in {:.1} KB, out {:.1} KB): median {:.2} ms",
            config.len() as f64 / 1024.0,
            out_len as f64 / 1024.0,
            samples[rounds / 2].as_secs_f64() * 1000.0,
        );
    }
}
