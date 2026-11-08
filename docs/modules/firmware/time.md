# 时间、NTP 与 RTC

本页覆盖时间获取、DS3231 backup 和 timezone/DST。源码事实以 `myTime.cpp` 为准；RTC 硬件见 [hardware](../hardware/README.md)。

## 1. 栈

固件使用 [AceTime](https://github.com/bxparks/AceTime) 和 `AceTimeClock`：

- `NtpClock ntpClock` — reference clock，用 `config.ntp_server` 配置。
- `DS3231Clock<WireInterface> dsClock` — I2C 上的 battery-backed backup。
- `SystemClockLoop systemClock` — 组合 reference 和 backup。
- `ExtendedZoneManager` + `zonedbx` zone/link registry + 3 项 `ExtendedZoneProcessorCache` — 用 `config.timezone` 把 epoch seconds 转 local time。

`Wire.begin()` 使用 ESP8266 默认 I2C 引脚（除非 schematic 另有说明，一般是 GPIO4/5）。`DS3231Clock::setup()` 和 `systemClock->setup()` 的返回值未检查。

## 2. 初始化与主循环

`syncTimeSetup()`：

1. placement-new `NtpClock(config.ntp_server)`。
2. 分配 `SystemClockLoop(&ntpClock, &dsClock)`。
3. `Wire.begin()`、`wireInterface.begin()`。
4. `dsClock.setup()`。
5. `ntpClock.setup()`；成功 log “NTP setup OK”，失败 log error。
6. `systemClock->setup()`。

`syncTimeLoop()` 每次主循环调用 `systemClock->loop()`。display 每秒调用 `getLocalTime()` 两次。

`getLocalTime()`：

1. `systemClock->getNow()` 取 epoch seconds。
2. `manager.createForZoneName(config.timezone)` 建 `TimeZone`。
3. `ZonedDateTime::forEpochSeconds(...)` 转 local time。
4. 把 year/month/day/hour/minute/second 复制到固件 `Time` 结构。
5. 调 `printCurrentTime()` — debug 残留，计算但不打印。

## 3. Timezone 与 DST

- `config.timezone` 是 IANA 名，如 `Europe/Budapest`；完整 `zonedbx` registry 编译进固件。
- DST 由 timezone 规则自动处理；没有 manual offset 或 DST switch。
- 字符串**不校验**。未知名称很可能被 AceTime 当作 unknown/UTC zone；新时区先在 hardware 上验证。
- 每次 `getLocalTime()` 都重复 timezone lookup；3 项 cache 共享，但仍比缓存稳定配置的 `TimeZone` 更费。
- Web UI 改 timezone 会 save + reboot；下次 boot 使用新 zone。

实际 K4-03 保存了 `Pacific/Auckland` 和 `nz.pool.ntp.org`；第二次 boot 加载了 zone，AceTime 的 TZDB 2023d 提供新西兰 DST 规则。这是部署时的时区数据库快照，不保证未来法律变化。见 [deployment record](../../evidence/2026-07-23-k4-03-deployment.md)。

## 4. 失败行为

- NTP 不可达：`ntpClock.setup()` log error；预期 `SystemClockLoop` 使用 DS3231 backup。具体 fallback 时机是库行为，本 workspace **未在 hardware 上验证**。
- DS3231 缺失或电池没电：`dsClock.setup()` 未检查；有网络时仍可能靠 NTP 运行，但失败不会明确 log。
- 两者都不可用：system clock 可能未设置；display 显示 epoch 派生值。UI 没有“time not set”状态。
- 掉电：DS3231 电池用于保持时间；电池状态和漂移未测。
- 实际 K4-03 上 maintainer 反馈断网后能自动恢复；这是人工观察，不是 isolated RTC-only test，RTC/Wi-Fi 路径仍未分别验证。

## 5. 测试检查单

- NTP 可达的冷启动：serial 显示 NTP setup OK；display 到正确 local time。
- 阻断 NTP 的冷启动：serial 显示 NTP error；display 使用 DS3231 并保持时间。
- DST 切换：display 在配置 zone 的切换点自动变化，无需 manual setting。
- 非法 timezone：观察实际 fallback 并记录；不要假设。
- 装 RTC 电池 power-cycle：时间保持。
- 拔电池 power-cycle：记录恢复时间和 display 期间显示什么。
- Web UI 改 timezone：reboot 后新 local time 和 DST 规则生效。

## 6. 相关阅读

- [Configuration](configuration.md) — `ntp_server`、`timezone`、save/reboot 路径。
- [Display](display.md) — 时间如何显示。
- [Logging](logging.md) — NTP/RTC error message。
- [Hardware](../hardware/README.md) — DS3231 和 I2C 引脚。
