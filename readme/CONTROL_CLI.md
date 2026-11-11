# 桌面端命令行控制（Bettbox CLI）

桌面版在后台常驻时，可以不带界面地读写它的状态：所有命令都转给**正在运行的实例**，
执行结果走 GUI 自己的路径（切订阅 → 重新下发配置，开关 TUN → 走原有提权逻辑），
因此状态与界面、`config.json` 始终一致。

## 用法

安装包会把可执行文件放到 `PATH`（`/usr/bin/Bettbox`），直接带参数运行即可：

```bash
Bettbox status                       # 单行 JSON：内核状态 / 模式 / TUN / 端口 / 当前订阅
Bettbox profiles                     # 订阅列表（含 current / loaded 标记）
Bettbox profile 魔戒                  # 按 label 或 id 切换订阅
Bettbox mode global                  # rule | global | direct
Bettbox tun on                       # on | off
Bettbox core restart                 # start | stop | restart | status
Bettbox profile-update all           # 更新全部订阅（不带参数=当前订阅）
Bettbox apply                        # 重新下发配置
Bettbox dns                          # 刷新 DNS 缓存
Bettbox help                         # 命令表
```

- 输出写到 stdout，错误写 stderr；返回码 `0` 成功、`1` 失败（回执以 `error:` 开头）。
- 实例没在跑时报 `error: Bettbox is not running (no control socket: ...)`，返回码 1，
  **不会**顺手拉起一个界面。
- `Bettbox --exit` / `Bettbox --restart` / `Bettbox show` 保持原语义（退出 / 自重启 / 显示窗口）。

## 协议

命令通道就是原有的控制 socket（`ExternalControl`）：

| 平台 | 地址 |
|---|---|
| Linux / macOS | `<应用数据目录>/Bettbox.control.sock`（dev 版本为 `BettboxDev.control.sock`） |
| Windows | `<应用数据目录>/Bettbox.control.port`（loopback TCP 端口号） |

一行一条命令（`\n` 结尾），服务端回一行结果后关闭连接；`exit/restart/show`
没有回执，直接断开。便携版（portable）不启动该通道。
