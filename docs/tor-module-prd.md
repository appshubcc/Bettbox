# Bettbox Tor Module PRD

## 1. 背景

Bettbox 是基于 Mihomo(Clash Meta) 内核的多平台代理客户端，当前核心体验围绕订阅导入、节点选择、TUN/VPN、系统代理、规则分流、Android 分应用代理和运行状态面板展开。

本 PRD 参考 `D:\code\private\hiddify-app` 的 Tor 模块设计，但不直接复刻 Hiddify 的 sing-box 配置模型。Bettbox 的 Tor 能力应作为现有 Mihomo 代理链路之上的可选增强路径，而不是替代当前节点选择、测速、连接状态和配置编辑能力。

核心语义必须保持清晰：

- 普通连接状态表示：本机 -> Bettbox/Mihomo -> 当前策略组选中节点或规则结果 -> 目标网络。
- Tor 状态表示：本机 -> Bettbox/Mihomo 当前代理出口 -> Tor 网络 -> 目标网络。
- Tor 失败不应改变主连接状态，不应把代理节点测速结果改写为 Tor 路径测速结果。

## 2. 产品目标

1. 为 Android 用户提供内置 Tor 出口能力，在不安装 Orbot 的情况下将指定流量送入 Tor 网络。
2. 在受限网络下支持 Tor bridge，包括 Direct、obfs4、Snowflake 和 meek。
3. 保持 Bettbox 原有 Mihomo 节点体验：节点选择、策略组、延迟测试、TUN/VPN、分应用代理和日志体系继续可用。
4. 提供独立 Tor 状态、Bootstrap 进度、出口地区和 Tor 路径延迟，避免用户把 Tor 问题误判为节点问题。
5. 以 Android MVP 为第一阶段，桌面端 Tor 作为第二阶段设计，不阻塞 Android 交付。

## 3. 非目标

1. 不把 Bettbox 改造成 Tor Browser 或通用匿名浏览器。
2. 不让所有用户默认启用 Tor。
3. 不用 Tor 替代现有代理节点、策略组或规则分流。
4. 不将节点测速、代理连通性测试、订阅更新请求默认改为 Tor 请求。
5. 不在 MVP 内承诺 Tor UDP 转发。Tor 普通流量仅支持 TCP，DNS 走单独策略。
6. 不在 MVP 内实现 iOS Tor。iOS 后台、VPN 和动态库限制需要独立评估。

## 4. 用户范围

主要用户：

- Android 用户，希望在现有代理连接可用后，为敏感应用或全局代理流量增加 Tor 出口。
- 网络环境中直连 Tor 被干扰，需要 obfs4、Snowflake 或 meek bridge 的用户。
- 高级用户，需要自定义 bridge lines 并观察 Tor bootstrap 失败原因。

暂不优先：

- 只需要普通节点代理和规则分流的用户。
- 希望所有 App 流量自动匿名化但不理解性能损耗和 UDP 限制的用户。

## 5. 平台范围

### 5.1 MVP

Android：

- 内置 Tor 二进制和必要 pluggable transport。
- 支持 Direct、obfs4、Snowflake、meek。
- 支持自定义 bridge。
- 支持全局代理流量进入 Tor。
- 支持 Android 分应用代理场景中按应用启用 Tor。
- 支持 Tor 状态卡片、日志和出口检测。

### 5.2 后续阶段

Windows、macOS、Linux：

- 可复用 Dart 状态模型、配置改写器和 UI。
- 需要分别处理 Tor 二进制打包、进程管理、权限、签名、公证和防火墙提示。
- 桌面端是否使用内置 Tor 或调用系统 Tor，应另写实现方案。

## 6. 用户设置

建议位置：

```text
设置 -> 网络 / VPN / 高级
```

新增设置：

```text
启用 Tor: bool，默认 false
Tor Bridge 模式:
- Direct
- obfs4，默认
- Snowflake
- meek

启用自定义 Bridge: bool，默认 false
自定义 Bridge: 多行文本，默认空

Tor 分流模式:
- 跟随当前代理范围，默认
- 仅分应用标记 Use Tor 的应用，Android include 模式下可用

允许局域网共享 Tor SOCKS: bool，默认 false，后续可选
Tor SOCKS 共享端口: int，默认 19050，仅共享开启时可编辑
```

配置持久化建议放入现有 `AppSettingProps` 或独立 `TorProps`：

```text
tor.enable
tor.bridgeMode
tor.customBridgesEnabled
tor.customBridges
tor.shareEnabled
tor.sharePort
```

自定义 Bridge 解析要求：

- 同时支持 `\n`、`\r\n`、`\r`。
- 忽略空行。
- 每行写成独立 `Bridge ...`。
- 自定义 Bridge 启用且非空时优先于内置 bridge。
- Bridge 基础格式错误应在启动前提示具体行号。

## 7. 信息架构与 UI

### 7.1 首页状态

Tor 关闭：

```text
主连接按钮、代理延迟、流量统计、内存状态保持现状
Tor 状态卡隐藏
```

Tor 开启：

```text
主连接状态: 仍表示 Mihomo/VPN 状态
代理延迟: 仍表示当前节点或策略组延迟
Tor 状态卡: 独立展示 Tor 状态
```

Tor 状态卡内容：

- Tor 图标和状态标题。
- Bootstrap 百分比。
- 当前阶段或失败摘要。
- 连接成功后显示 Tor 出口国家、城市、IP。
- 连接成功后显示 Tor 路径延迟。
- 提供查看 Tor 日志入口。

状态映射：

```text
disabled -> 未启用
starting -> 启动中
bootstrapping -> 连接中 N%
ready -> 已连接
failed -> 失败
stopping -> 停止中
```

### 7.2 分应用代理

当前 Bettbox 已有 Android `AccessControl`：

```text
rejectSelected
acceptSelected
```

Tor MVP 需要在 Android 分应用代理列表中增加应用级 Tor 标记：

- 仅在 Tor 启用时显示。
- 仅在该应用属于当前代理范围时显示。
- 推荐 UI 为 `Use Tor` FilterChip 或 Switch。
- 关闭 Tor 后隐藏应用级 Tor 标记，但不删除用户保存的标记，便于下次恢复。

## 8. 状态模型

产品层必须拆分三类状态：

```text
CoreStatus
- stopped
- starting
- running
- stopping
- failed

ProxyHealthStatus
- unknown
- testing
- available
- timeout
- failed

TorStatus
- disabled
- starting
- bootstrapping
- ready
- failed
- stopping
```

允许状态组合：

```text
Core running + Tor bootstrapping
=> 主状态显示已连接
=> 节点延迟显示节点延迟
=> Tor 卡片显示 Connecting N%

Core running + Tor failed
=> 主状态显示已连接
=> 节点延迟保持原值
=> Tor 卡片显示失败原因

Proxy timeout + Tor ready
=> 节点测速仍可显示 timeout
=> Tor 卡片可显示 ready，二者互不覆盖
```

禁止行为：

- Tor 失败导致主按钮回到连接中。
- Tor 超时导致所有节点测速 timeout。
- Tor GeoIP 失败导致主连接断开。
- Bridge 启动失败触发订阅或节点配置重写。

## 9. 端口规划

固定本地端口：

```text
Tor SOCKS: 127.0.0.1:19050
Tor Control: 127.0.0.1:19051
Tor DNSPort: 127.0.0.1:19053
```

Tor bootstrap 上游代理：

```text
127.0.0.1:<Mihomo mixed-port>
```

要求：

- 优先读取当前实际 Mihomo `mixed-port`。
- 如果用户配置没有 mixed-port，Tor 启动前应确保创建一个本地 mixed inbound，默认建议 `12334` 或复用项目现有默认端口。
- 不使用固定的 `19052` 作为 Tor 上游代理入口，避免端口语义混乱。

## 10. 启动与停止流程

### 10.1 Android 启动流程

```text
1. 用户点击启动 Bettbox 或重新连接
2. 启动/重启普通 Mihomo core
3. 等待 VPN/TUN 和 mixed-port 可用
4. 如果 Tor 未启用，流程结束
5. 如果 Tor 启用，停止旧 Tor 进程和旧 transport
6. 根据当前配置生成 Tor routing patch
7. 应用 Mihomo Tor 路由改写
8. 启动 native Tor，Socks5Proxy 指向 127.0.0.1:<mixed-port>
9. bridge 模式需要先启动对应 pluggable transport
10. 通过 EventChannel/MethodChannel 推送 TorStatus
11. ready 后执行 Tor 出口 GeoIP 和延迟检测
```

### 10.2 停止流程

```text
1. 用户停止 Bettbox 或关闭 VPN
2. 停止 native Tor
3. 停止 pluggable transport
4. 停止或恢复 Mihomo core
5. 发布 TorStatus.disabled
6. 清理临时配置文件，不删除 Tor data directory
```

### 10.3 重新连接

以下场景需要重启 Tor：

- 修改 bridge 模式。
- 修改自定义 bridge。
- 当前 mixed-port 变化。
- 切换主代理节点后用户选择重新连接。
- Android VPN 服务被系统杀死后恢复。

以下场景不应强制重启 Tor：

- 普通节点测速。
- 查看日志。
- 首页 UI 重建。
- GeoIP 检测失败。

## 11. 流量路径

### 11.1 Tor 关闭

```text
App traffic -> Android VPN/TUN -> Mihomo -> 当前规则/策略组 -> target
```

### 11.2 Tor bootstrap

Direct：

```text
Tor process -> Socks5Proxy 127.0.0.1:<mixed-port> -> Mihomo -> 当前代理出口 -> Tor guard
```

obfs4 / meek：

```text
Tor process -> ClientTransportPlugin local socks5
transport -> socks5://127.0.0.1:<mixed-port> -> Mihomo -> 当前代理出口 -> bridge
```

Snowflake：

```text
Tor process -> Snowflake transport
Snowflake rendezvous/bridge traffic -> socks5://127.0.0.1:<mixed-port> -> Mihomo -> 当前代理出口
```

要求：

- Snowflake 也必须走当前 mixed-port 上游代理。
- Tor bootstrap 不应直连，除非用户明确选择允许直连 bootstrap 的高级选项。

### 11.3 应用 TCP

全局代理范围：

```text
Proxied TCP -> VPN/TUN -> Mihomo Tor rule -> tor-out -> 127.0.0.1:19050 -> Tor network -> target
```

分应用代理 + Use Tor：

```text
Selected app TCP -> VPN/TUN -> package rule -> tor-out -> 127.0.0.1:19050 -> Tor network -> target
```

分应用代理 + 未 Use Tor：

```text
Selected app TCP -> VPN/TUN -> 原 Bettbox/Mihomo 规则 -> target
```

### 11.4 UDP

Tor 不承载普通 UDP：

- DNS UDP/TCP 53 应被 hijack 到 DNS 处理链路。
- 进入 Tor 范围的非 DNS UDP 应 reject，并在日志中可见。
- 未进入 Tor 范围的 UDP 保持原有 Mihomo 行为。

## 12. Mihomo 配置改写

Bettbox 使用 Mihomo YAML/JSON 配置，不应照搬 sing-box `outbounds` 和 `route.rules` 字段。需要实现 Bettbox 专用 `TorConfigTransformer`。

建议生成逻辑：

1. 确保存在本地 SOCKS5 proxy provider/outbound，名称固定为 `TOR` 或 `tor-out`。
2. 该 outbound 指向：

```yaml
name: tor-out
type: socks5
server: 127.0.0.1
port: 19050
udp: false
```

3. 在 rules 中插入高优先级 Tor 规则：

```yaml
- PROCESS-NAME / PACKAGE-NAME,xxx,tor-out
- NETWORK,TCP,tor-out
- NETWORK,UDP,REJECT
```

具体规则语法必须以 Mihomo 当前支持为准，进入实现前需要基于内核版本验证。

4. 避免污染用户原始订阅：

- 改写只写入运行时临时配置。
- 原始 profile 内容不落盘修改。
- 停止 Tor 后恢复普通运行时配置。

5. 如果当前配置没有 mixed-port：

- 运行时补充 mixed-port。
- 或提示用户启用 mixed-port，MVP 推荐自动补充。

## 13. DNS 设计

目标：

- Tor 范围内的域名解析不应从本地网络或普通代理 DNS 泄漏。
- 非 Tor 范围内的 DNS 行为尽量保持原样。

MVP 方案：

1. Tor 范围内 DNS 请求劫持到 Mihomo DNS。
2. 为 Tor 流量指定远程 DoH/DoT 解析，并通过 `tor-out` detour 或等价机制发送。
3. 如果 Mihomo 无法为 DNS server 设置代理 detour，则 MVP 需要二选一：

- 阻止 Tor 模式启动并提示 DNS 配置不支持。
- 或允许启动，但明确标记 DNS 防泄漏未满足，不能作为正式验收通过。

验收必须覆盖：

- Tor App 的 TCP 和 DNS 出口均为 Tor。
- 非 Tor App 的 DNS 不应被强制改到 Tor，除非技术限制被明确记录。

## 14. Tor 原生模块

Android 原生模块职责：

- 管理 `libtor.so` 或等价 Tor binary。
- 管理 IPtProxy / pluggable transport runtime。
- 生成 `torrc`。
- 启停 Tor 进程。
- 解析 stdout 中的 Bootstrap 进度。
- 推送状态和错误。
- 维护 Tor data directory 与 pt-state directory。

`torrc` 必要字段：

```text
SocksPort 127.0.0.1:19050
ControlPort 127.0.0.1:19051
DNSPort 127.0.0.1:19053
CookieAuthentication 1
DataDirectory <app-files>/tor/data
ClientOnly 1
AvoidDiskWrites 1
Log notice stdout
Socks5Proxy 127.0.0.1:<mixed-port>
```

Bridge 模式附加：

```text
UseBridges 1
ClientTransportPlugin <transport-name> socks5 <local-transport-address>
Bridge <bridge-line>
```

Transport 映射：

```text
Direct -> no transport
obfs4 -> obfs4 transport
Snowflake -> snowflake transport
meek -> meek_lite transport
```

启动前检查：

- mixed-port 可连接。
- Tor binary 存在且可执行。
- transport 启动后返回有效 local address。
- 自定义 bridge 非空且基础格式有效。
- 固定端口未被占用。

## 15. 出口检测与延迟

Tor ready 后，由 Dart 层通过 Tor SOCKS 发起 GeoIP 请求：

```text
Dart HTTP client -> SOCKS5 127.0.0.1:19050 -> Tor -> GeoIP provider
```

推荐 GeoIP fallback：

```text
1. https://ipwho.is/
2. https://api.ip.sb/geoip/
3. https://ipapi.co/json/
4. https://ipinfo.io/json/
```

要求：

- GeoIP 请求必须强制走 Tor SOCKS。
- 不复用普通节点测速结果。
- 不写回代理延迟。
- Tor 延迟定义为 Tor GeoIP 请求开始到首个有效响应的耗时。
- GeoIP 全部失败时，Tor 状态仍可保持 ready，但出口信息显示不可用。

## 16. 日志与诊断

新增日志分类：

```text
Tor process
Tor transport
Tor config transform
Tor DNS
Tor GeoIP
```

用户可见错误示例：

- Tor 上游代理 `127.0.0.1:<mixed-port>` 未就绪。
- Tor binary 缺失。
- obfs4/Snowflake/meek transport 启动失败。
- Bridge 第 N 行格式错误。
- Tor process exited。
- Bootstrap 卡在某百分比超过超时。
- Tor DNS 配置不可用。

诊断导出需要包含：

- Tor 设置摘要，隐藏敏感 bridge 参数中的 cert 可选。
- torrc，隐藏敏感字段。
- 最近 Tor 日志。
- 当前 mixed-port。
- 当前是否启用 VPN/TUN。
- Android 分应用 Tor 标记列表。

## 17. 安全与隐私

1. Tor 默认关闭。
2. 开启时明确提示性能下降、UDP 限制、部分网站不可用。
3. 自定义 bridge 属于敏感配置，日志和诊断导出应脱敏。
4. 不向第三方服务上传 Tor 使用状态。
5. GeoIP provider 请求只用于本地展示，不作为遥测。
6. Tor data directory 不应在普通清理缓存时误删，除非用户选择重置 Tor。

## 18. 性能与稳定性

验收指标：

- Tor 关闭时启动耗时和内存占用与当前版本无显著回退。
- Tor 开启但 bootstrap 失败时，Mihomo 主连接仍可长期运行。
- Android 后台运行时，Tor 进程被系统回收后能显示准确失败状态。
- 切换网络后可触发 Tor 重连，但不造成 UI 状态循环闪烁。
- 非 Tor 用户不加载 Tor transport，避免无意义内存占用。

## 19. MVP 验收标准

1. Tor 默认关闭，关闭时 Bettbox 行为完全不变。
2. Android 打开 Tor 后，主连接状态和 Tor 状态独立显示。
3. Direct、obfs4、Snowflake、meek 四种模式至少各有一条可验证路径。
4. 自定义 bridge 支持 CRLF、LF、CR 多行输入。
5. Tor bootstrap 上游走当前 Mihomo mixed-port。
6. 切换 bridge 模式会正确停止旧 transport 并启动新 transport。
7. Tor ready 后，`127.0.0.1:19050` 可作为 SOCKS5 出口访问网络。
8. Tor 出口国家、城市、IP 和 Tor 延迟独立展示。
9. Tor GeoIP 失败不影响主连接状态和节点延迟。
10. 全局 Tor 模式下，匹配的 TCP 走 Tor，非 DNS UDP 被拒绝。
11. 分应用 Tor 模式下，只有标记 Use Tor 的应用 TCP 走 Tor。
12. DNS 防泄漏行为被自动化或手工测试验证。
13. 停止 Bettbox 后 Tor 和 transport 进程均退出。
14. 诊断日志可定位 Tor binary、transport、bridge、DNS 和 upstream 失败。
15. 原始订阅/profile 文件不会被 Tor 配置改写污染。

## 20. 实施拆分

### Phase 1: 产品与架构

- 增加 `TorProps` 配置模型。
- 增加 Tor 状态模型和 provider。
- 增加 Android MethodChannel/EventChannel 协议定义。
- 增加运行时 Mihomo Tor 配置改写器设计和单元测试。

### Phase 2: Android Native Tor

- 打包 Tor binary。
- 集成 pluggable transport。
- 实现 `TorProcessManager`。
- 实现 `torrc` 生成、进程管理、bootstrap 解析和错误上报。

### Phase 3: 路由与 DNS

- 实现 mixed-port 检测和补充。
- 实现 Tor outbound 与 rule patch。
- 实现 Android 分应用 Use Tor 标记。
- 验证 DNS 防泄漏。

### Phase 4: UI 与诊断

- 设置页增加 Tor 配置。
- 首页增加 Tor 状态卡。
- 分应用代理 UI 增加 Use Tor 控件。
- 日志和诊断导出增加 Tor 分类。

### Phase 5: 验证与发布

- Android 真机测试。
- bridge 模式网络测试。
- 回归普通代理、TUN、系统代理、智能启停、休眠恢复。
- 编写用户文档和风险提示。

## 21. 开放问题

1. Mihomo 当前版本能否用规则稳定区分 Android package 并仅对指定包送入 `tor-out`？
2. Mihomo DNS 是否支持对指定规则的 DNS 请求强制经 `tor-out`，还是需要额外本地 DNSPort/DoH 方案？
3. Tor binary 和 pluggable transport 的 Android ABI、许可证和签名策略如何纳入现有构建流程？
4. 是否需要提供“允许 Tor bootstrap 直连”的高级选项？
5. Tor retry 是否独立于主连接重连，还是复用现有重连按钮？
6. 是否需要内置 bridge 列表更新机制，还是仅随 App 版本发布？
7. 桌面端 Tor 是否进入同一 PRD 的 Phase 6，还是拆成单独 PRD？
