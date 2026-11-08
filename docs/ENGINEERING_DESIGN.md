# 工程设计导航

这是导航，不是合同正文。行为合同在 `docs/modules/`，验证资格在 `docs/VALIDATION.md`。

## 1. 系统上下文

ESP-12F 驱动 4 片 74HC595D shift register（四位数字 + 两个秒点 LED），通过 I2C 读取 DS3231，通过 `A0` 读取光敏，并用 Wi-Fi 提供 NTP、配置 portal、OTA 和 syslog。实际 fork 机器是 K4-03；硬件见 [hardware](modules/hardware/README.md)。

## 2. 运行时流程

`setup()`：serial 115200 → 加载 `/halclock.conf` → display 初始化 → NTP/RTC 初始化 → WiFiManager menu → 连接或启动 portal → OTA（定义 `ENABLE_OTA` 时）→ 记录 reset reason → 3 秒 watchdog-off delay → 8 秒 watchdog。

`loop()`：`wm.process()` → `systemClock->loop()` → 每 500 ms display refresh → `ArduinoOTA.handle()` → `wdt_reset()`。

display 每次 refresh 读取 local time；time 层组合 NTP 和 DS3231。Web UI 只改配置，保存后重启。

## 3. 模块映射

| 源码 | 职责 | 合同 |
|---|---|---|
| `ChineseWallClock.ino` | boot/loop、配置、portal、OTA、reset log、watchdog | [firmware](modules/firmware/README.md) |
| `myConfig.*` | `Config`、默认值、引脚、AP 身份 | [configuration](modules/firmware/configuration.md) |
| `myDisplay.*` | shift register、数字、亮度、scheduler | [display](modules/firmware/display.md) |
| `myTime.*` | AceTime NTP + DS3231 + timezone/DST | [time](modules/firmware/time.md) |
| `myLogging.*` | Serial + 可选 syslog | [logging](modules/firmware/logging.md) |

## 4. 横切合同

- **Config：** LittleFS `/halclock.conf`；默认值在 `myConfig.h`；load/save 的 boolean 拼写不同（`"true"` vs `"1"`）；save 后 reboot。
- **Time：** AceTime `SystemClockLoop` 中 `NtpClock` 为 reference、`DS3231Clock` 为 backup；timezone 是 `zonedbx` IANA 名；DST 来自数据库。
- **Display：** LSB-first shift + latch；segments active-low；manual brightness 对 `SR_OE` 反相；`A0` auto brightness 覆盖 manual。
- **Identity：** AP/hostname `halclock` + chip ID；AP password `password`；OTA password = AP 名；Web UI 无认证。
- **Logging/watchdog：** serial 始终输出；配置后 lazy 创建 syslog，facility `LOCAL7`；8 秒 watchdog 由 loop 和 OTA 重置。

## 5. 设计决定与约束

- Arduino/ESP8266 + WiFiManager：易上手，但依赖多、测试有限。
- LittleFS + ArduinoJson：无需外部服务的本地配置；save document 容量有限。
- AceTime + 完整 timezone database：不依赖每次 boot 的网络查询即可处理 DST；代价是代码大小和重复 zone lookup。
- `libraries/libraries.zip` 固定 build；没有自动化测试，真实测试循环是 compile + 物理时钟。
- tracked tree 是 upstream 工作；fork 的 build/deployment 记录放 history/evidence，不能并入 upstream history。

## 6. 阅读映射

| 要改什么 | 读哪里 |
|---|---|
| Web 表单、默认值、持久化、WiFi/OTA | [configuration](modules/firmware/configuration.md) |
| 数字、亮度、leading zeros、clever `1`、秒点 LED | [display](modules/firmware/display.md) |
| NTP、DS3231、timezone/DST | [time](modules/firmware/time.md) |
| log 格式、syslog | [logging](modules/firmware/logging.md) |
| build、libraries、image offset、flash | [build and flash](modules/build-and-flash/README.md) |
| 端到端部署 | [deployment](modules/deployment/README.md) |
| factory image 或原厂 UI | [factory firmware](modules/factory-firmware/README.md) |
| schematic、pinout、datasheet | [hardware](modules/hardware/README.md) |

## 7. 已知设计债

- Web UI 无认证；AP password 硬编码；OTA password 是 AP 名。
- `clever` 不序列化；配置损坏/缺失时不一定回退默认值。
- 每次 refresh 都重复 timezone lookup；`printCurrentTime()` 是 no-op；`warningLog()` 未使用；仍有 string-literal warnings。
- upstream 报告 Web UI firmware upload broken；serial/OTA 是已知路径，但本 fork 未验证。

未决项记录在 `docs/DEVELOPMENT.md` §5；本页不授权修复。
