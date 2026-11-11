# 固件总览

固件是一个 Arduino sketch 加四个小 module。本页是阅读导航和横切合同；具体改动看链接的专题页。

本 fork 的实际机器是两台 K4-03。software/deployment 路径（build、flash、verify、boot、config、Wi-Fi 复用）已通过；第二台另有 flash/verify/boot/Web UI 和手动配置后的人工反馈。display/RTC 细节和自动亮度根因仍为 partial。见 [deployment record](../../evidence/2026-07-23-k4-03-deployment.md) 和 [第二台记录](../../evidence/2026-11-11-k4-03-second-unit-deployment.md)。

## 1. 源码映射

| 文件 | 职责 | 何时读 |
|---|---|---|
| `ChineseWallClock.ino` | `setup()`/`loop()`、配置、WiFiManager menu、OTA、reset log、watchdog | 改 boot、portal、OTA 或生命周期时 |
| `myConfig.h`、`myConfig.cpp` | `Config`、默认值、shift register 引脚、AP 身份 | 改设置、引脚或身份时 |
| `myDisplay.h`、`myDisplay.cpp` | shift register 输出、数字、亮度、500 ms scheduler | 改显示时 |
| `myTime.h`、`myTime.cpp` | AceTime NTP + DS3231、timezone/DST | 改时间源或时区时 |
| `myLogging.h`、`myLogging.cpp` | Serial 和可选 syslog | 改日志时 |

## 2. 启动与主循环

`setup()`：

1. `Serial.begin(115200)`，输出 `Booting`。
2. 从 LittleFS 加载 `/halclock.conf`；文件不存在则用默认值。
3. 输出当前配置。
4. 初始化 display，在时间未就绪时显示 `2020`。
5. 通过 AceTime `SystemClockLoop` 初始化 NTP + DS3231。
6. 建立 WiFiManager 参数 menu，连接 WiFi 或启动 non-blocking portal。
7. 如果 `myConfig.h` 定义了 `ENABLE_OTA`，启动 ArduinoOTA。
8. 记录 reset reason；关闭 watchdog，`delay(3000)`，启用 `WDTO_8S`。

`loop()` 调用 `wm.process()`、time loop、500 ms display scheduler、启用时的 `ArduinoOTA.handle()`，最后 `wdt_reset()`。

## 3. 已实现行为

- **配置 UI：** WiFiManager portal，包含 device name、NTP server、timezone、syslog server、brightness 和四个 checkbox（second blinking、clever numbering、leading zeros、automatic brightness）。
- **时间：** NTP 是 reference source，DS3231 是 backup；时区和 DST 来自 AceTime `zonedbx` 中配置的 IANA 名。
- **显示：** 四位数字显示时和分；可选秒点 LED 闪烁；可选 leading zeros；leading `1` 的 clever glyph；manual 或 automatic brightness。
- **网络：** AP/hostname 为 `halclock` + 大写 chip ID；AP password `password`；hostname 同名；WiFiManager retry 5 次；连接成功后 portal 仍可用。
- **OTA：** Arduino IDE network upload，password 为 AP 名；`ENABLE_OTA` 控制是否编译。
- **日志：** serial 115200 和可选 UDP syslog，facility `LOCAL7`。
- **Watchdog：** 8 秒，主 loop 和 OTA progress 都会 reset。

未完成产品项（timezone dropdown、Web UI password、MQTT、Web UI firmware upload）只在 `docs/DEVELOPMENT.md` §5 维护。

## 4. 横切不变量

- **一个配置对象。** `Config config` 是全局；load 在使用者之前，save 只从 portal callback 进入并以 `wm.reboot()` 结束。
- **Display 节奏。** `syncDisplayScheduler()` 每 500 ms refresh，每次都读取 local time。不要加第二个 display update loop。
- **时间源。** `NtpClock` 是 reference，`DS3231Clock` 是 backup；consumer 调 `getLocalTime()`，不直接读 NTP/RTC。
- **身份。** AP SSID、hostname、OTA password 都由 `getAPName()` 派生；改一个会改其他。
- **Logging 是全局的。** 第一次 log 可能创建 syslog client；改 `syslog_server` 需要 reboot（save 路径会 reboot）。
- **Watchdog。** 超过 8 秒不 `wdt_reset()` 会 reset。

<a id="known-implementation-notes"></a>

<a id="known-implementation-notes"></a>

## 5. 已知实现问题

以下来自代码审阅，不是 hardware 复现：

- `saveConfiguration()` 不写 `clever`；下次 load 缺 key 时回退 `"true"`。取消 clever 很可能在 reboot 后恢复。见 [configuration defects](configuration.md#known-persistence-defects)。
- LittleFS mount 失败或 JSON parse error 只记 log，不应用默认值；全局 `Config` 可能保持全零。见 [configuration defects](configuration.md#known-persistence-defects)。
- `loadConfiguration()` 用 `sizeof(config.ntp_server)` 复制 `timezone`；两者当前都是 64 bytes，暂时无害但脆弱。
- `saveConfiguration()` 使用 `StaticJsonDocument<256>` 装四个 64-byte 字符串加 key；长值可能偏紧。加字段前用最大长度测试。
- `printCurrentTime()` 每次 `getLocalTime()` 都调用，但只计算不输出，是 debug 残留。
- `warningLog()` 实现了但未使用。
- `logResetReason()` 和若干 logging 调用把 string literal 赋给 `char*`，产生 `-Wwrite-strings` warning；build 有 14 个 warning、0 error。
- `secondLedsOn` 用 `millis() % 1000`，blink 相位相对 boot，不是 RTC 秒。
- `dsClock.setup()` 和 `systemClock->setup()` 的返回值未检查；RTC 缺失不会被明确报告。

## 6. 阅读映射

| 任务 | 下一页 |
|---|---|
| 默认值、JSON、Web form、WiFi、OTA | [configuration](configuration.md) |
| 数字、亮度、leading zeros、clever `1`、秒点 LED | [display](display.md) |
| NTP、DS3231、timezone/DST | [time](time.md) |
| Serial/syslog 格式 | [logging](logging.md) |
| Build/flash/deploy | [build and flash](../build-and-flash/README.md)、[deployment](../deployment/README.md) |

<a id="open-product-items"></a>

<a id="open-product-items"></a>

## 7. 未完成产品项

upstream README 仍列出 timezone dropdown、password-protected Web UI、MQTT 和断掉的 Web UI firmware upload。状态和下一步只在 `docs/DEVELOPMENT.md` §5 维护；本页不复制或关闭它们。
