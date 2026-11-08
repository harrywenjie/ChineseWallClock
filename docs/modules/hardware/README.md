# 硬件

本页记录时钟硬件和打开、编程、恢复所需的物理接口。upstream 目标是 **K2-02**；本 fork 实际机器是 **K4-03**。部署记录：[2026-07-23 K4-03](../../evidence/2026-07-23-k4-03-deployment.md)。

## 1. 设备差异

upstream 板是 Baiyangshu 1902 Wifi Clock **K2-02**。实际 fork 机器是 **K4-03**：ESP8266EX、26 MHz crystal、**4 MB flash**、`COM3` 上的 CP210x USB-UART。两者都是四位 LED 时钟，都有 4 片 74HC595D 和 DS3231，但电气等价性**未证明**。upstream KiCad schematic [`KiCad/schematic.pdf`](../../../KiCad/schematic.pdf) 是 K2-02 参考，不是 K4-03 保证。

![设备](../../images/device_picture.png)

display 是四个七段 digit，每段 4 个并联 LED，另有两个秒点 LED。

## 2. 主要元件

| 元件 | 作用 | 说明 |
|---|---|---|
| **ESP-12F / ESP8266EX** | 控制、WiFi、Web UI、OTA | 3.3 V logic；实际 K4-03 为 4 MB flash |
| **4 × 74HC595D** | serial-to-parallel shift register chain | 驱动 segments 和秒点 LED；OE 用于 PWM brightness |
| **DS3231SM** | I2C battery-backed RTC | 温度传感器约 ±3 °C；板上没有其他温度传感器 |
| **光敏** | 环境亮度输入 | ESP `A0` ADC；用于 auto brightness |
| **6-pin 编程 header** | serial 编程/恢复 | pads |

ESP 用四个 GPIO 控制 shift register chain，用 OE PWM 控制亮度；DS3231 走 I2C。原厂固件能显示温度，但传感器精度是为 RTC 补偿设计的，不是室温测量。

## 3. 编程 header 与 UART

实际 K4-03 header：

| Pin | Signal | 说明 |
|---|---|---|
| 1 | `FLASH` / GPIO0 | 拉低进 bootloader |
| 2 | 可能是 `RST` | 部署时未接 CP210x |
| 3 | `GND` | common ground |
| 4/5 | `RXD0` / `TXD0` 这一对 | 通信已验证；文字记录未最终确定哪针是 TX/RX |
| 6 | `+5V` | 时钟供电；不用于给 CP210x 供电 |

upstream README 的顺序相同（`RDX0` 是 `RXD0` 的笔误），并说第六针最靠近 ESP-12F。上电前用照片和通断测量确认物理方向。

![编程接口](../../images/programming_interface.jpg)

实际接线：CP210x `GND` → board `GND`；clock TX → CP210x RXD；clock RX ← CP210x TXD；CP210x `+5V`/`3V3` 不接；时钟用自己的 USB-A 供电。CP210x `RST`/`DTR`/`RTS` 不接，所以没有自动 reset。Boot mode：GPIO0 → GND，然后重新上电；esptool 需要 `--before no-reset --after no-reset`。

注意：

- ESP8266 是 **3.3 V**。`TXD0`/`RXD0` 用 3.3 V USB-TTL；`+5V` 引脚不代表 I/O 耐 5 V。
- 焊接 header 前先拍照并记录线序。
- 未确认板子电源路径时，不要把时钟 `+5V` 接到 programmer 的 5 V 供电。

## 4. 固件使用的引脚

| 功能 | GPIO | 来源 |
|---|---|---|
| shift register serial data（`SR_SER`） | 13 | `myConfig.h` |
| shift register shift clock（`SR_SRCLK`） | 14 | `myConfig.h` |
| shift register latch clock（`SR_RCLK`） | 12 | `myConfig.h` |
| shift register output enable（`SR_OE`） | 15 | `myConfig.h`；inverted，PWM brightness |
| DS3231 I2C | 默认 `Wire` 引脚（GPIO4/5） | `Wire.begin()`；K2-02 schematic 已确认 |
| 光敏 | `A0` | `myDisplay.cpp` |

`SR_OE` active-low。固件写 255 表示 off，manual brightness 写 `255 - config.brightness`。

**GPIO15 boot 风险：** GPIO15 是 ESP8266 boot strap，K2-02 schematic 上被下拉；74HC595 OE 又是 active-low。reset/boot 早期 shift register 输出可能短暂使能，直到 `displaySetup()` 拉高 OE。K4-03 上先把它当 hardware 观察，不要先归因固件。

## 5. 显示映射

digit mapping 是 board-specific。权威表在 `myDisplay.h`；`docs/display/digits on display.ods` 记录 segment 编号和 active-low 规则；手写照片 `docs/display/IMG20240320232149.jpg` 是 reverse engineering 记录。

- segment 在对应 bit 为 **0** 时点亮。
- `mapping[]` 是标准表；`mappingClever[]` 只改 digit `1` 的 glyph。
- `DIGIT_OFF`/`DIGIT_DASH` 是 index 18/19。
- 固件按 digit1→digit4、LSB-first 发送；K2-02 假设 cascade 是 U4→U3→U2→U1。

K4-03 初次 boot 和目视正常，但详细 segment/ghosting/秒点测试未记录。

## 6. 参考文档

- [KiCad schematic](../../../KiCad/schematic.pdf)
- [74HC595 datasheet](../../datasheets/74HC595.pdf)
- [DS3231 datasheet](../../datasheets/ds3231.pdf)
- [ESP-12F datasheet](../../datasheets/ESP-12F/a014ps01.pdf)
- [ESP8266 module manual](../../datasheets/ESP-12F/esp8266_series_modules_user_manual_v1.1.pdf)
- [ESP-12E pinout](../../datasheets/ESP-12F/ESP-12E-Pinout.jpg)
- [Display 编号](../../display/digits%20on%20display.ods)、[照片](../../display/IMG20240320232149.jpg)
- [K4-03 deployment](../../evidence/2026-07-23-k4-03-deployment.md)
- [K4-03 hardware preparation](../../evidence/2026-07-23-k4-03-hardware-preparation.md)、[backup manifest](../../evidence/2026-07-23-k4-03-backup-manifest.md)

## 7. 已知与未知

- 已知：K4-03、ESP8266EX、26 MHz、4 MB、`COM3` 上的 CP210x；完整 4,194,304-byte per-unit backup，SHA-256 `59FC…E37E`，私有保存。它包含已保存的 Wi-Fi 配置，不得进入 Git。
- upstream `factory_firmware/image4M.bin` 是 4,000,000-byte K2-02 dump，**不是** K4-03 恢复镜像。
- 未知：K2-02 与 K4-03 电气差异、光敏 polarity/response、K4-03 display mapping 细节、DS3231 detection log、蓝灯行为（固件不控制）。
