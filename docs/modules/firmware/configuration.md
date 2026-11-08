# 配置、Web UI、WiFi 与 OTA

本页是运行时设置和配置 portal 的合同。源码事实以 `myConfig.h` / `ChineseWallClock.ino` 为准；这里说明预期行为和已知缺陷。

## 1. 配置字段

| 字段 | 类型 | 默认值 | JSON key | Web 控件 | 说明 |
|---|---|---|---|---|---|
| `syslog_server` | `char[64]` | 私有 LAN 地址（见 `myConfig.h`） | `syslog_server` | text | 默认会启用 syslog；长度 > 1 时第一次 log 创建 client |
| `device_name` | `char[64]` | `HalClock` | `device_name` | text | 作为 WiFiManager 页面标题；AP/hostname 另由 chip ID 派生 |
| `ntp_server` | `char[64]` | `hu.pool.ntp.org` | `ntp_server` | text | 传给 AceTime `NtpClock` 的主机名或 IP |
| `timezone` | `char[64]` | `Europe/Budapest` | `timezone` | text | 必须是 AceTime `zonedbx` 的 IANA 名；固件不校验 |
| `leading_zeros` | `bool` | `true` | `leading_zeros` | checkbox | 关闭时消掉时/分十位的 leading zero |
| `clever` | `bool` | `true` | `clever` | checkbox | leading `1` 用 alternate glyph；**save 不写这个 key** |
| `second_blinking` | `bool` | `false` | `second_blinking` | checkbox | 每 500 ms 切换秒点 LED |
| `brightness` | `byte` | `255` | `brightness` | number 0–255 | manual 亮度；Web save clamp 到 1–255，load 不 clamp |
| `auto_brightness` | `bool` | `true` | `auto_brightness` | checkbox | 用 `A0` 光敏值覆盖 manual brightness |

默认值在 `myConfig.h`。`auto_brightness_minimum_light` 是 245；display code 把它当 PWM 上限，而不是“最低光照”阈值，名字有误导。

## 2. 持久化格式

文件是 LittleFS `/halclock.conf`。正常 save 写紧凑 JSON；boolean 存 `"true"` / `"false"`，brightness 存字符串。默认值形态如下：

```json
{"device_name":"HalClock","ntp_server":"hu.pool.ntp.org","timezone":"Europe/Budapest","syslog_server":"<syslog-host>","second_blinking":"false","leading_zeros":"true","auto_brightness":"true","brightness":"255"}
```

`<syslog-host>` 代表 `myConfig.h` 中的私有 LAN 默认值；部署时换成自己的 collector。

`clever` 缺失是 §6 的缺陷；load 时缺 key 会回退默认 `"true"`。

## 3. 加载路径

1. `LittleFS.begin()` mount。
2. 如果 `/halclock.conf` 存在，打开并解析到 `StaticJsonDocument<512>`。
3. 每个字段用 `| default` 复制；boolean 比较存储字符串与 `"true"`；brightness 用 `atoi`。
4. 文件不存在时应用全部默认值。
5. 文件存在但 parse 失败，或 filesystem mount 失败时，只记 log，**不应用默认值**；全局 `Config` 可能保持全零（空字符串、false、brightness 0）。

timezone 的复制用 `sizeof(config.ntp_server)`，不是 `sizeof(config.timezone)`。两者当前都是 64 bytes，没有溢出，但表达式是错的，改动时应修。

## 4. 保存路径

`saveParamsCallback()` 把 form 值复制进 `config`，把 brightness clamp 到 1–255，调用 `saveConfiguration()`，然后 `wm.reboot()`。

`saveConfiguration()`：

1. mount LittleFS。
2. 删除旧文件（否则库会 append）。
3. 新建写入文件。
4. 建 `StaticJsonDocument<256>`，写字段但**不写 `clever`**，brightness 用 `itoa`，序列化到文件，并把 JSON echo 到 Serial，关闭文件。
5. 文件创建或写入失败时记 error 并返回。

256-byte document 对四个 64-byte 字符串加 key/value 偏紧。默认值和短值可以工作；加字段前用最大长度测试。

## 5. Web UI 与 WiFiManager

portal menu 是 `wifi`、`info`、`param`、`sep`、`restart`。`wm.setTitle(config.device_name)` 提供页面标题，`wm.setHostname(getAPName())` 设置 hostname。form 有九个字段，顺序为：device name、NTP server、timezone、syslog server、brightness、second blinking、clever、leading zeros、auto brightness。

checkbox 提交 `"1"`，`saveParamsCallback()` 用 `"1"` 比较；JSON 用 `"true"` / `"false"`。加字段时两套拼写要同步。

WiFi 设置：

- AP/hostname：`halclock` + `WIFI_getChipId()` 的大写 hex。
- AP password：硬编码 `password`。
- `setConnectRetries(5)`、non-blocking portal、auto-reconnect 开启。
- 成功后 `wm.startWebPortal()`，Web UI 在 station network 上继续可用。
- 失败时 configuration AP 保留，`loop()` 用 `wm.process()` 服务它。

README 说“配置后 AP 关闭”是 WiFiManager 行为，不是固件显式动作；依赖前先在目标机器上验证。hostname 的 mDNS 解析未验证；用 portal/serial log 显示的 IP。

## 6. 已观察到的 K4-03 配置

实际机器首次启动没有 `/halclock.conf`，所以用默认值：`Europe/Budapest`、`hu.pool.ntp.org`、device name `HalClock`、clever `1`、second blinking `0`、brightness `255`、leading zeros `1`、auto brightness `1`。

随后 portal 保存：

| 字段 | 值 |
|---|---|
| NTP server | `nz.pool.ntp.org` |
| Timezone | `Pacific/Auckland` |
| Syslog server | 空（disabled） |
| Second blinking | on |
| Clever numbering | on |
| Leading zeros | on |
| Auto brightness | on |
| Brightness | 255 |

serial echo 中 `clever` 缺失是 §7 的缺陷；保存文件仍以默认 `true` 加载。syslog 是 UDP 514；空 server 禁用 client。Wi-Fi 配置不在 `/halclock.conf`，而在 ESP8266 SDK flash 区，sketch-only flash 会保留它。后来 maintainer 发现自动亮度偏暗，改为固定 manual brightness；具体值和切换时间未记录。见 [deployment record](../../evidence/2026-07-23-k4-03-deployment.md)。

<a id="known-persistence-defects"></a>

<a id="known-persistence-defects"></a>

## 7. 已知持久化缺陷

以下来自代码审阅，不是 hardware 复现：

- **`clever` 不保存。** 字段会 load、会显示，但 `saveConfiguration()` 从不写它。取消 clever 并 save，reboot 后很可能回到 `true`。
- **parse/mount 失败不应用默认值。** 错误路径只 log，全局 config 保持全零。损坏文件可能产生空 device name、空 NTP/timezone/syslog 和 brightness 0；display 可能黑掉。
- **Load 的 brightness 不 clamp。** Web save clamp 1–255；其他方式写入的值赋给 `byte` 时可能 wrap。
- **Save document 偏小。** 四个 64-byte 字符串加 key 可能超过 `StaticJsonDocument<256>`。
- **timezone 用 NTP 字段大小复制。** 两个都是 64 bytes 时无害，但脆弱。

## 8. OTA 与安全

- `ENABLE_OTA` 在 `myConfig.h` 定义；只有定义时才编译 OTA。
- `ArduinoOTA.setHostname(getAPName())`、`ArduinoOTA.setPassword(getAPName())`；OTA password 就是可发现的 AP 名。
- OTA progress 调 `wdt_reset()`；正常 upload 不会被 8 秒 watchdog 打断。
- Web UI 无认证。AP password 硬编码，OTA password 可预测。把设备当作可信家庭网络设备，不要暴露到互联网。
- `saveConfiguration()` 把 JSON（含 syslog 地址）echo 到 Serial。不要在不可信环境保存 serial log。

## 9. 改动检查单

加/改配置字段时：

1. 更新 `Config`、默认宏和 `loadConfiguration()`。
2. 更新 `menuSetup()` 和 `saveParamsCallback()`。
3. 更新 `saveConfiguration()`，检查 JSON document 容量。
4. 更新本页；行为变化时更新入口当前快照。
5. 测试：首次 boot 默认值、save、power-cycle 持久化、最大长度、损坏 JSON，以及对应的 display/network 效果。

## 10. UI 参考

这些 inherited upstream 截图展示 portal 布局和 upstream 固件的真实部署。它们是参考媒体，不是本 fork 的部署证据；值是示例，不是默认值。网络标识不转写。

- [Landing page](../../images/main_page.png) — title、hostname/IP、Configure WiFi / Info / Setup / Restart。
- [Setup page](../../images/setup_page.png) — 配置字段和 checkbox。
- [WiFi page](../../images/wifi.png) — SSID/password form、scan、refresh。

## 11. 测试检查单

- 无 `/halclock.conf` 的全新 boot 显示文档默认值。
- 每个字段 save + reboot 后保留；重点测 `clever` 和 `leading_zeros`。
- 损坏 JSON 和缺失 filesystem 能被有意恢复（当前是已知缺陷）。
- brightness 0、1、255、256 行为符合预期；auto brightness 覆盖 manual。
- 非法 timezone 会被可见地回退或拒绝（当前不校验）。
- AP SSID/password、portal title、station IP 和 OTA password 与本页一致。
- Web UI firmware upload 已知 broken；修好并验证前用 serial 或 OTA。
