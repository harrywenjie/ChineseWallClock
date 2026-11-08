# 2026-07-23 K4-03 硬件准备

本页记录 K4-03 成功刷写前的物理准备和串口排障，基于 maintainer 提供的第二份 Codex 总结，补充 [部署记录](2026-07-23-k4-03-deployment.md)。它不是厂家 schematic。

## 1. 设备和工具

| 项目 | 实际值 |
|---|---|
| 主板丝印 | `BAIYANGSHU WiFi Clock K4-03` |
| Upstream 目标 | `Baiyangshu 1902 WiFi Clock K2-02` |
| MCU / module | ESP-12F；esptool 识别 `ESP8266EX` |
| Crystal | 26 MHz |
| Flash | 4 MB = 4,194,304 bytes |
| Flash ID | `Manufacturer: 20`、`Device: 4016` |
| USB-UART | CP2102，header `3V3 / TXD / RXD / GND / +5V` |
| Windows port | `COM3`（重新插拔或换电脑要重新确认） |
| 工具 | Windows 11、PowerShell、Python、Arduino IDE；esptool **5.3.1** |
| 仓库 | `E:\ChineseWallClock` |

目标是关闭原厂固件的常驻 AP，改用可维护的开源固件。原厂 serial log 证实它同时运行 STA + SoftAP。替换固件保留 Wi-Fi 配置、关闭 configuration AP，并且（per maintainer）断网后能自动恢复；长期 Wi-Fi 稳定性没有单独测量。

## 2. 编程 header：实际确认了什么

下面的“左到右”只指**这块板**的观察方向，不是所有 K4-03 的通用 pin 1 定义。

| 位置 | 确认情况 | 注意 |
|---|---|---|
| 1 | **FLASH / GPIO0 已确认** | 拉低、重新上电；esptool 连接并完成两次 backup |
| 2 | **本次未确认** | upstream K2-02 称 RST，但本次没接、没用 |
| 3 | **GND 已确认** | 与时钟 USB-A power GND 通断；A/B/C 共地测试通过 |
| 4/5 | **Serial pair 通信确认** | 初始接法无有效输出；交换两根线后成功。文字记录没有最终分配哪根是 MCU TX/RX |
| 6 | **+5V 可用于时钟** | 稳定方案不用它；时钟自己 USB-A 供电 |

### TX/RX 方向

正确关系按 signal direction 记，不要照抄 pin 号：

```text
clock TX（输出 log） ─────→ CP2102 RXD
clock RX（接收命令） ←───── CP2102 TXD
```

能读原厂 log 只证明 clock→PC 方向。esptool 识别 chip、读取 flash 才证明双向通信。

## 3. 最终供电和接线

```text
clock USB-A ─────────────── clock power
PC USB ──────────────────── CP2102 power

CP2102 GND ──────────────── board pin 3 GND
CP2102 RXD ←─────────────── board actual TX
CP2102 TXD ───────────────→ board actual RX

CP2102 +5V                 不接
CP2102 3V3                 不接
board pin 2                不接；RST 未使用
仅在下载模式：
board pin 1 FLASH/GPIO0 ─── board GND
```

时钟和 CP2102 各自供电、共享 common ground。时钟 USB-A 有地，不代表可以省掉 serial 双方的 common reference。

避免：

- 时钟用自己 USB 供电时，接 CP2102 `+5V` 或 `3V3`；
- 把 board `+5V` 当 UART logic level；
- 认为有 `3V3` 引脚就代表 TXD 电平已经测过——本次没有保留独立 TXD 电压测量。

## 4. 焊接故障和恢复

焊接/接线期间，时钟一度没有蓝灯、没有 serial 输出，看起来像变砖。**当时还没有写 firmware。** 清理焊点、移除外部接线、只用时钟 USB-A 供电后恢复，能连原 Wi-Fi 并打开原厂页面。

结论：证据支持焊接/接触/boot-strap 状态问题，不是 factory image 损坏。没有记录具体 short，所以不能断言是某个焊盘连锡。

经验：

1. 焊接、清理、通断测量前断开电源和 jumpers。
2. 两面都检查 bridge、cold joint、stray wire、pad edge。
3. 肉眼看不出 bridge 不等于连接可靠。
4. 用实际 USB-A power ground 作 reference，不用 USB shell。
5. 蜂鸣档不能代替完整判断；结合阻值、走线和实际工作状态。
6. 线要 strain-relieve；read/write 时不要碰线。
7. 异常时断电，回到 minimal wiring；不要靠反复上电或擦写“抢救”。
8. 蓝灯不亮、display 不亮不能证明 chip 坏；GPIO0 拉低时原厂 application 本来就不运行。

## 5. “接 GND 就不启动”的排查

时钟曾在接 CP2102 GND 时不启动，拔掉恢复，让人怀疑 programming GND 没通或厂家防刷。后来：

- pin 3 确实与 USB-A power ground 导通；
- 异常时 CP2102 `+5V` **没有**接，所以“双 5 V 供电”不是已证明原因；
- 三个最小测试通过：

| 测试 | 接线 | 结果 |
|---|---|---|
| A | 各自供电，只接 GND | 正常启动 |
| B | A + clock TX → CP2102 RXD | 能读原厂 serial log |
| C | B + CP2102 TXD → clock RX | 仍正常；双向通信成功 |

common-ground 方案本身正确，GND 不是空脚。早期异常的精确原因没有确定；重点转到 FLASH 接线和 boot order。

最有效的方法是**每次只加一根线**，隔离变量，而不是一次接满后猜。

## 6. 串口和下载模式

Windows 识别 `Silicon Labs CP210x USB to UART Bridge (COM3)`。Arduino Serial Monitor 和 Python miniterm 都能用，但同一时刻只能有一个程序占用 `COM3`。

原厂 log 命令：

```powershell
py -m serial.tools.miniterm COM3 115200
```

退出 `Ctrl+]`。

交换 TX/RX 后有数据但乱码；切到 `115200` 后读到清晰原厂 ASCII。部分中文仍乱码，不代表 serial link 失败。`74880` 是 ESP8266 ROM boot message，不是 application log；download-mode 成功的证据是 esptool 连接，不是保存了 ROM log。

想看最早 boot message，保持 CP2102 和 serial monitor 连着，只给时钟重新上电；拔掉 CP2102 会让 COM port 消失。

手动下载模式：

```text
clock off → FLASH/GPIO0 to GND → clock on → run esptool
```

GPIO0 必须在 reset/boot 时 low；原厂 application 已经运行后再接不够。

成功识别：

```powershell
py -m esptool --chip esp8266 --port COM3 --baud 115200 `
  --before no-reset --after no-reset chip-id

py -m esptool --chip esp8266 --port COM3 --baud 115200 `
  --before no-reset --after no-reset flash-id
```

观察到：`Connected to ESP8266 on COM3`、`Chip type: ESP8266EX`、`Crystal frequency: 26MHz`、`Chip ID: <private>`、`Detected flash size: 4MB`。Chip ID/MAC suffix 是私有硬件标识，公开记录不重复。

`Hard resetting via RTS pin...` 只是工具消息，不是 board reset 证据。RTS 没接；命令同时使用 `--before no-reset` 和 `--after no-reset`。

## 7. Factory backup

私有 backup 目录里有 verified full image 和 hash/restore notes。历史读取命令：

```powershell
Set-Location <private-backup-dir>

py -m esptool --chip esp8266 --port COM3 --baud 115200 `
  --before no-reset --after no-reset `
  read-flash 0x000000 0x400000 K4-03_factory_1.bin

py -m esptool --chip esp8266 --port COM3 --baud 115200 `
  --before no-reset --after no-reset `
  read-flash 0x000000 0x400000 K4-03_factory_2.bin
```

每次约 **382.9 秒**、约 **87.6 kbit/s**。两个文件都是 4,194,304 bytes，SHA-256 都是 `59FC45E91B37DCAD5C4E60E90416E3351D303A7CB8739B791CBD999FDC0CA37E`。

刷写后不要用同名文件再读，会覆盖 factory backup。当前私有目录有 `K4-03_FACTORY_VERIFIED.bin`，hash 相同。原始 image **不复制进仓库**，由 maintainer 私有保存。见 [backup manifest](2026-07-23-k4-03-backup-manifest.md)。

两次读取成功不等于 restore 已经测试。**Restore 仍是 NOT_RUN。**

## 8. 自动亮度发现

刷后 `Auto Brightness` 能用但偏暗。Upstream code：

```cpp
int brightness_level = 255 - config.brightness;
if (config.auto_brightness) {
    brightness_level = sensorBridghtness();
}
```

auto mode **覆盖** manual `Brightness`，不是 baseline 或 offset。映射大致是：

```text
sensorValue = analogRead(A0)
brightness_level = min(sensorValue / 4, 245)
```

OE 控制是 inverted：PWM 越小越亮，越大越暗。没有采集不同光照下的 A0，也没有记录最终 core 的 PWM 配置。“偏暗”可能来自 upstream mapping、光敏分压或 K4-03 差异；原因未证明。

Maintainer 的 workaround 是关闭 auto brightness、用固定 manual 值；具体值和时间未记录。Auto brightness 是 **open usability issue**，不是 passed feature。

## 9. 兼容性边界

upstream code 定义 GPIO15（OE）、GPIO12（latch）、GPIO14（shift clock）、GPIO13（data）、`A0` 光敏、DS3231 over `Wire`。这些是 **code 定义**，不是对 K4-03 全部走线的通断测量。成功 boot 只证明这台机器上已测功能兼容，不证明所有 K4-03 revision。

## 10. 下一台机器的检查单

- [ ] 焊接前断电；两面检查 bridge、cold joint、strain。
- [ ] 用真实 power ground 和通断确认 pin，不信另一块板的“左起”。
- [ ] pin 1 FLASH、pin 3 GND 已确认；pin 2 未验证；拍照记录 pin 4/5 最终方向。
- [ ] 时钟自己 USB 供电；CP2102 只接 GND/RX/TX；+5V/3V3 不接。
- [ ] 先接 GND，再接 receive，最后接 transmit。
- [ ] 能读 log 只证明 clock→PC；用 esptool 证明双向。
- [ ] 下载前 GPIO0 low，正常 boot 前移除。
- [ ] 不把无 LED/无 display/RTS 文本当损坏或 reset 的证据。
- [ ] 两次完整 backup，size/hash 匹配；不要覆盖 factory image。
- [ ] 不公开含已保存 Wi-Fi 配置的 factory image 或 raw log。
- [ ] flash 成功、functional test pass、restore test 是三件不同的事。

## 11. 相关记录

- [K4-03 部署记录](2026-07-23-k4-03-deployment.md) — build、flash、verify、boot、config。
- [Backup manifest](2026-07-23-k4-03-backup-manifest.md) — 私有 backup 和 hash。
- [Hardware](../modules/hardware/README.md) — 元件、pin、注意事项。
- [Deployment runbook](../modules/deployment/README.md) — 可重复流程。
