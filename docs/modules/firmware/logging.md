# 日志与 Syslog

本页覆盖 serial/syslog logging 路径。源码事实以 `myLogging.cpp` 为准。

## 1. API

四个 varargs helper 共享 `logging()`：

| 函数 | 严重级别 | 典型用途 |
|---|---|---|
| `debugLog()` | `PRI_DEBUG` | boot、config、filesystem、WiFi 细节 |
| `infoLog()` | `PRI_INFO` | 生命周期、AP 身份、OTA start/end |
| `warningLog()` | `PRI_WARNING` | **当前源码未使用** |
| `errorLog()` | `PRI_ERROR` | filesystem、brightness clamp、WiFi/OTA 错误 |

每条消息用 `vasprintf()` 格式化，按 `[LEVEL] message` 打到 Serial，配置了 syslog 时发送，然后 free。每条消息动态分配一次，诊断用途正常，但 tight loop 里频繁 log 有 fragmentation 风险。

## 2. 串口

`setup()` 最先 `Serial.begin(115200)`。第一行是 `[INFO] Booting`。boot log 随后包含有效配置、AP name/password、NTP 结果、WiFi 结果、OTA 状态和 reset reason。部署时这是主要诊断通道；刷写前后都保留。

## 3. Syslog

- `strlen(config.syslog_server) <= 1` 时 disabled。
- 第一次 log 且 server 字符串更长时，创建 `SimpleSyslog`：
  - hostname `getAPName()`；
  - application name `APPLICATION_NAME`（`HalClock`）；
  - 配置的 server 地址。
- 消息使用 `FAC_LOCAL7` 和上面的 severity。
- client 是全局、lazy 的；改 `syslog_server` 需要 reboot 才重建。Web save 已经 reboot。
- 默认 server 是 `myConfig.h` 里的私有 LAN 地址。用默认值时第一次 log 就会尝试 syslog，即使没有 collector；UDP 失败不会上报。
- 实际 K4-03 部署把 `syslog_server` 留空，禁用 remote client。传输是 UDP 514；只使用可信 collector，地址保持私有。
- Syslog 是 plain UDP，无认证、无加密。只在可信网络使用。

## 4. 消息约定

- 前缀方括号 severity：`[INFO]`、`[DEBUG]`、`[WARNING]`、`[ERROR]`。
- 使用 ESP8266 `printf` 支持的 `%s`、`%d`、`%.2f`；`%zu`/`%llu` 要先验证。
- 新代码不要 log 凭据、WiFi password 或完整配置 dump。现有 save 路径会把 JSON 配置（含 syslog 地址）echo 到 Serial；捕获的 log 视为敏感。
- `logResetReason()` 把 ESP8266 reset reason 映射成可读字符串。

## 5. 测试检查单

- Serial 115200 显示 boot、config、AP 身份和 reset reason。
- syslog server 为空时不创建 client。
- collector 可达时，消息以 `LOCAL7` 和预期 severity 到达。
- collector 不可达时，boot 和 display 不被阻塞。
- Web UI 改 syslog server 后 reboot 生效。
