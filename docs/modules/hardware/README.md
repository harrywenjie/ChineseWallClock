# Hardware

This page documents the clock hardware and the physical interfaces needed to open, program or restore it. It is based on the inherited upstream README, schematic and datasheets; fork-specific hardware changes are not recorded.

## 1. Device

The target is a **Baiyangshu 1902 Wifi Clock K2 02** — a four-digit LED wall clock sold with a “BAIYANGSHU” factory firmware. The PCB is clean, single-board and simple to program. The full KiCad schematic is [`KiCad/schematic.pdf`](../../../KiCad/schematic.pdf).

![Device](../../images/device_picture.png)

The display is made of four large seven-segment digits, each segment built from four parallel LEDs, plus two second LEDs in the colon area.

## 2. Main components

| Component | Role | Notes |
|---|---|---|
| **ESP-12F** (ESP8266) | Controller, WiFi, web UI, OTA | 3.3 V logic; 4 MB flash class; exact module marking on the board is `ESP-12F` |
| **4 × 74HC595D** | Serial-to-parallel shift register chain | Drives the segments and second LEDs; output enable used for PWM brightness |
| **DS3231SM** | Battery-backed RTC on I2C | Includes a temperature sensor with roughly ±3 °C accuracy; no other temperature sensor on the PCB |
| **Light sensor** | Environment brightness input | Connected to the ESP `A0` ADC; used by automatic brightness |
| **6-pin programming header** | Serial programming / recovery | Unpopulated pads; see §3 |

The ESP controls the shift-register chain with four GPIOs and the display brightness with PWM on the output-enable pin. The DS3231 is managed over I2C. The original firmware can display temperature, but the sensor's accuracy was intended for RTC compensation, not room-temperature measurement.

## 3. Programming header

The board has an unplaced 6-pin connector. The inherited README lists the pins in this order:

1. `FLASH`
2. `RST`
3. `GND`
4. `RDX0` (the README spelling; the ESP pin is `RXD0`)
5. `TXD0`
6. `+5V`

The README also says the sixth pin (+5V) is the one closest to the ESP-12F. The programming-interface photo shows the physical order and is the better orientation reference; verify continuity against the schematic before applying power.

![Programming interface](../../images/programming_interface.jpg)

Practical cautions:

- The ESP8266 is a **3.3 V** part. Use a 3.3 V USB-TTL adapter for `TXD0`/`RXD0`; do not assume the `+5V` pin makes the I/O 5 V tolerant.
- `FLASH` is labelled like the ESP8266 boot-mode pad (usually GPIO0). The usual serial-flash procedure is to pull it low and pulse `RST`, but this is a board-specific inference — confirm on the schematic and your adapter before flashing.
- The header is unpopulated; soldering a pin header is a physical modification. Photograph the board and record the wire order before soldering.
- Never connect the clock's `+5V` to a programmer's 5 V supply without checking the board's power path. Power the clock from its own supply where possible.

## 4. Pin assignments used by the firmware

| Function | GPIO | Source |
|---|---|---|
| Shift-register serial data (`SR_SER`) | 13 | `myConfig.h` |
| Shift-register shift clock (`SR_SRCLK`) | 14 | `myConfig.h` |
| Shift-register latch clock (`SR_RCLK`) | 12 | `myConfig.h` |
| Shift-register output enable (`SR_OE`) | 15 | `myConfig.h`; inverted, PWM brightness |
| DS3231 I2C | default `Wire` pins (GPIO4/5 on ESP8266) | `Wire.begin()`; confirm on schematic |
| Light sensor | `A0` | `myDisplay.cpp` |

`SR_OE` is active-low. The firmware writes 255 for off and `255 - config.brightness` for manual brightness.

## 5. Display mapping

The digit byte mapping is specific to this board's wiring. The authoritative tables are in `myDisplay.h`; `docs/display/digits on display.ods` records the segment numbering and the active-low rule. The handwritten photo `docs/display/IMG20240320232149.jpg` shows the segment numbering used during reverse engineering.

- Segments are ON when the related bit is **zero**.
- `mapping[]` is the standard glyph table; `mappingClever[]` changes only the glyph for digit `1`.
- `DIGIT_OFF` and `DIGIT_DASH` are synthetic entries at indices 18 and 19.

Do not replace these tables with a generic seven-segment table without a hardware check.

## 6. Reference documents

- [KiCad schematic](../../../KiCad/schematic.pdf)
- [74HC595 datasheet](../../datasheets/74HC595.pdf)
- [DS3231 datasheet](../../datasheets/ds3231.pdf)
- [ESP-12F datasheet](../../datasheets/ESP-12F/a014ps01.pdf)
- [ESP8266 series module manual](../../datasheets/ESP-12F/esp8266_series_modules_user_manual_v1.1.pdf)
- [ESP-12E pinout](../../datasheets/ESP-12F/ESP-12E-Pinout.jpg)
- [Display segment numbering](../../display/digits%20on%20display.ods), [photo](../../display/IMG20240320232149.jpg)

These are inherited upstream reference files. They describe the hardware, not a fork-specific modification.

## 7. What is not known

- The exact board revision, flash size and flash mode are not recorded in the tracked repository. The factory dump is 4,000,000 bytes, which is **not** a full 4 MiB dump; see [factory firmware](../factory-firmware/README.md).
- The light-sensor divider polarity and response curve are not documented; automatic brightness must be checked on the target unit.
- The programming header's physical pin-1 orientation is only shown in the photo; verify with continuity, not label order alone.
- No fork-specific hardware modification or per-unit serial number is recorded. The fork deployment record is **待核实**; see `docs/DEVELOPMENT.md` §5.
