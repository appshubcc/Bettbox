# 桌面端命令行控制（Bettbox CLI）

桌面版在后台常驻时，可以不带界面地读写它的状态：所有命令都转给**正在运行的实例**，
执行结果走 GUI 自己的路径（切订阅 → 重新下发配置，开关 TUN → 走原有提权逻辑），
因此状态与界面、`config.json` 始终一致。

安装包会把可执行文件放到 `PATH`（`/usr/bin/Bettbox`），直接带参数运行即可。

## 语法

```
Bettbox [<scope>] <option> [<value>...] [--json]
```

- `<scope>` 是**名词**作用域：`profiles` / `mode` / `tun` / `core` / `settings`；
  省略作用域时选项作用于 APP 本身。
- 每个作用域只写一个选项；**裸 `<scope>` 等价于 `<scope> --status`**。
- `--json` 输出单行 JSON（脚本用），默认输出对齐后的文本。
- `-h` / `--help` 不带作用域给全局帮助，带作用域给该作用域的全部选项说明。
- 作用域后面直接跟值的位置写法等价于对应动作，方便手敲：
  `Bettbox mode global` = `Bettbox mode --switch global`，
  `Bettbox tun on` = `Bettbox tun --enable`，
  `Bettbox core restart` = `Bettbox core --restart`，
  `Bettbox profiles 魔戒` = `Bettbox profiles --select 魔戒`，
  `Bettbox settings mixed-port 8080` = `Bettbox settings --set mixed-port 8080`。
- 不带任何参数 = 正常启动界面；参数是桌面文件传进来的路径或 URL 时同样走 GUI。

## 命令表

### 顶层（APP 本身）

| 命令 | 说明 |
|---|---|
| `Bettbox --status` | 内核 / 模式 / TUN / 端口 / 当前订阅快照 |
| `Bettbox --refresh-dns` | 刷新 DNS 缓存 |
| `Bettbox --show` | 显示主窗口 |
| `Bettbox --restart` | 重启应用 |
| `Bettbox --exit` | 退出应用 |
| `Bettbox --help` | 全局帮助 |

### `profiles`：订阅

| 命令 | 说明 |
|---|---|
| `Bettbox profiles --list` | 列出全部订阅（`current` / `loaded` 标记） |
| `Bettbox profiles --status` | 当前订阅与加载状态 |
| `Bettbox profiles --select <id|label>` | 切换订阅 |
| `Bettbox profiles --update [id|label|all]` | 更新订阅，省略或 `all` = 全部 |
| `Bettbox profiles --reapply` | 重新下发当前配置 |

### `mode`：出站模式

| 命令 | 说明 |
|---|---|
| `Bettbox mode --status` | 当前模式 |
| `Bettbox mode --switch rule|global|direct` | 切换模式 |

### `tun`

| 命令 | 说明 |
|---|---|
| `Bettbox tun --status` | TUN 开关与内核实际状态 |
| `Bettbox tun --enable` / `--disable` | 开关 TUN |

### `core`：内核

| 命令 | 说明 |
|---|---|
| `Bettbox core --status` | 内核运行状态 |
| `Bettbox core --start` / `--stop` / `--restart` | 启停 / 重启内核 |

### `settings`：GUI 专有配置项

| 命令 | 说明 |
|---|---|
| `Bettbox settings --list` | 列出可写字段与当前值 |
| `Bettbox settings --get <field>` | 读取单个字段 |
| `Bettbox settings --set <field> [value]` | 写入字段（`secret` 不带值 = 清除） |

可写字段：`mixed-port` `port` `socks-port` `redir-port` `tproxy-port` `log-level`
`ipv6` `tcp-concurrent` `unified-delay` `allow-lan` `find-process-mode`
`keep-alive-interval` `external-controller` `secret`。写入后立即落盘并下发配置。

## 输出与返回码

```bash
$ Bettbox --status
version    1.19.8+20261111
core       running
mode       rule
tun        on (real-tun off)
ports      mixed 7890 / http 7891 / socks 7892
lan        off
external   open (secret set)
log-level  info
profile    魔戒 (loaded)

$ Bettbox mode --status --json
{"ok":true,"data":{"mode":"rule"}}

$ Bettbox profiles --select 不存在的订阅
$ echo $?
1            # 回执以 error: 开头即失败
```

- 结果写 stdout、错误写 stderr；返回码 `0` 成功 / `1` 失败。
- `--json` 模式下失败输出 `{"ok":false,"error":"..."}`，返回码同样是 `1`。
- 实例没在跑时报 `error: Bettbox is not running (no control socket: ...)`，返回码 1，
  **不会**顺手拉起一个界面；`--help` 是唯一例外，它会打印离线用法提示。

## 兼容性

旧的扁平命令保留为别名，已经在用的第三方 socket 客户端不需要改：

| 旧命令 | 现在等价于 |
|---|---|
| `status` | `--status` |
| `profile <id|label>` | `profiles --select <id|label>` |
| `profiles` | 语义收窄：裸作用域现在等于 `profiles --status`，列表要写 `--list` |
| `profile-update [x]` | `profiles --update [x]` |
| `mode <x>` | `mode --switch <x>` |
| `tun on|off` | `tun --enable|--disable` |
| `core <action>` | `core --<action>` |
| `set <field> <value>` | `settings --set <field> <value>` |
| `apply` / `dns` | `profiles --reapply` / `--refresh-dns` |
| `show` / `exit` / `restart` | `--show` / `--exit` / `--restart` |
| `ping` | `--ping`（内部健康检查） |

## 协议

命令通道就是原有的控制 socket（`ExternalControl`）：

| 平台 | 地址 |
|---|---|
| Linux / macOS | `<应用数据目录>/Bettbox.control.sock`（dev 版本为 `BettboxDev.control.sock`） |
| Windows | `<应用数据目录>/Bettbox.control.port`（loopback TCP 端口号） |

一行一条命令（`\n` 结尾，内容与命令行的参数完全一致，例如 `profiles --select 魔戒`），
服务端回 0..N 行结果后关闭连接；`--exit/--restart/--show` 没有回执，直接断开。
便携版（portable）不启动该通道。

```bash
printf 'profiles --list --json\n' | nc -U ~/.local/share/com.appshub.bettbox/Bettbox.control.sock
```
