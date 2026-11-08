# Hardware

This page documents the clock hardware and the physical interfaces needed to open, program or restore it. The upstream target is the **K2-02**; this fork's actual unit is a **K4-03**. Deployment: [2026-07-23 K4-03](../../evidence/2026-07-23-k4-03-deployment.md).

## 1. Device variants

The upstream board is the Baiyangshu 1902 Wifi Clock **K2-02**. The actual fork unit is a **K4-03**: ESP8266EX, 26 MHz crystal, **4 MB flash**, CP210x USB-UART on `COM3`. Both are four-digit LED clocks with four 74HC595D shift registers and a DS3231, but electrical equivalence is **not proven**. The upstream KiCad schematic [`KiCad/schematic.pdf`](../../../KiCad/schematic.pdf) is a reference for the K2-02, not a K4-03 guarantee.

![Device](../../images/device_picture.png)

The display is four seven-segment digits, each segment built from four parallel LEDs, plus two second LEDs.

## 2. Main components

| Component | Role | Notes |
|---|---|---|
| **ESP-12F / ESP8266EX** | Controller, WiFi, web UI, OTA | 3.3 V logic; 4 MB flash on the actual K4-03 |
| **4 × 74HC595D** | Serial-to-parallel shift register chain | Drives segments and second LEDs; output enable used for PWM brightness |
| **DS3231SM** | Battery-backed RTC on I2C | Temperature sensor roughly ±3 °C; no other temperature sensor |
| **Light sensor** | Environment brightness input | ESP `A0` ADC; used by automatic brightness |
| **6-pin programming header** | Serial programming / recovery | Pads |

The ESP controls the shift-register chain with four GPIOs and brightness with PWM on the output-enable pin. The DS3231 is managed over I2C. The factory firmware can display temperature, but the sensor is intended for RTC compensation, not room-temperature measurement.

## 3. Programming header and UART

Actual K4-03 header:

| Pin | Signal | Notes |
|---|---|---|
| 1 | `FLASH` / GPIO0 | Pull to GND for the bootloader |
| 2 | likely `RST` | Not connected to the CP210x in the deployment |
| 3 | `GND` | Common ground |
| 4/5 | `RXD0` / `TXD0` pair | Communication confirmed; exact pin direction not finalized in the text |
| 6 | `+5V` | Clock power; not used to power the CP210x |

The upstream README lists the same order (with `RDX0` as a typo for `RXD0`) and says the sixth pin is closest to the ESP-12F. Verify the physical orientation against the photo and continuity before applying power.

![Programming interface](../../images/programming_interface.jpg)

Actual wiring: CP210x `GND` → board `GND`; clock TX → CP210x RXD; clock RX ← CP210x TXD; CP210x `+5V`/`3V3` not connected; clock on its own USB-A supply. CP210x `RST`/`DTR`/`RTS` not connected, so there is no automatic reset. Boot mode: GPIO0 → GND, then repower; esptool needs `--before no-reset --after no-reset`.

Cautions:

- The ESP8266 is **3.3 V**. Use a 3.3 V USB-TTL adapter for `TXD0`/`RXD0`; the `+5V` pin does not make the I/O 5 V tolerant.
- Photograph the board and record the wire order before soldering the header.
- Do not connect the clock's `+5V` to a programmer's 5 V supply without checking the board's power path.

## 4. Pin assignments used by the firmware

| Function | GPIO | Source |
|---|---|---|
| Shift-register serial data (`SR_SER`) | 13 | `myConfig.h` |
| Shift-register shift clock (`SR_SRCLK`) | 14 | `myConfig.h` |
| Shift-register latch clock (`SR_RCLK`) | 12 | `myConfig.h` |
| Shift-register output enable (`SR_OE`) | 15 | `myConfig.h`; inverted, PWM brightness |
| DS3231 I2C | default `Wire` pins (GPIO4/5) | `Wire.begin()`; confirmed on the K2-02 schematic |
| Light sensor | `A0` | `myDisplay.cpp` |

`SR_OE` is active-low. The firmware writes 255 for off and `255 - config.brightness` for manual brightness.

**GPIO15 boot risk:** GPIO15 is an ESP8266 boot strap pulled low on the K2-02 schematic, while the 74HC595 OE is active-low. Shift-register outputs can be enabled briefly during reset/boot before `displaySetup()` raises OE. On the K4-03, treat random segments at reset as a hardware observation first, not a firmware bug.

## 5. Display mapping

The digit mapping is board-specific. The authoritative tables are in `myDisplay.h`; `docs/display/digits on display.ods` records the segment numbering and active-low rule. The handwritten photo `docs/display/IMG20240320232149.jpg` shows the reverse-engineering numbering.

- Segments are ON when the related bit is **zero**.
- `mapping[]` is the standard table; `mappingClever[]` changes only the glyph for digit `1`.
- `DIGIT_OFF`/`DIGIT_DASH` are indices 18/19.
- The firmware sends digit1→digit4, LSB-first; the K2-02 cascade assumption is U4→U3→U2→U1.

The K4-03 boot and initial visual check looked normal, but detailed segment/ghosting/second-LED tests were not recorded.

## 6. Reference documents

- [KiCad schematic](../../../KiCad/schematic.pdf)
- [74HC595 datasheet](../../datasheets/74HC595.pdf)
- [DS3231 datasheet](../../datasheets/ds3231.pdf)
- [ESP-12F datasheet](../../datasheets/ESP-12F/a014ps01.pdf)
- [ESP8266 module manual](../../datasheets/ESP-12F/esp8266_series_modules_user_manual_v1.1.pdf)
- [ESP-12E pinout](../../datasheets/ESP-12F/ESP-12E-Pinout.jpg)
- [Display numbering](../../display/digits%20on%20display.ods), [photo](../../display/IMG20240320232149.jpg)
- [K4-03 deployment record](../../evidence/2026-07-23-k4-03-deployment.md)
- [K4-03 hardware preparation](../../evidence/2026-07-23-k4-03-hardware-preparation.md), [backup manifest](../../evidence/2026-07-23-k4-03-backup-manifest.md)

## 7. Known and unknown

- Known: K4-03, ESP8266EX, 26 MHz, 4 MB, CP210x on `COM3`; full 4,194,304-byte per-unit backup with SHA-256 `59FC…E37E`, stored privately. It contains the saved Wi-Fi configuration and must never enter Git.
- The upstream `factory_firmware/image4M.bin` is a 4,000,000-byte K2-02 dump, **not** a K4-03 restore image.
- Unknown: K2-02 vs K4-03 electrical differences, light-sensor polarity/response, detailed K4-03 display mapping, DS3231 detection logging, blue-LED behavior (not controlled by firmware).
