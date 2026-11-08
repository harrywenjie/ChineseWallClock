# 2026-07-23 K4-03 Hardware Preparation

This page records the physical preparation and serial troubleshooting that preceded the successful K4-03 flash on **2026-07-23**. It is based on a second user-provided Codex summary and complements the [deployment record](2026-07-23-k4-03-deployment.md). It is not a manufacturer schematic.

## 1. Device and tools

| Item | Actual |
|---|---|
| Board marking | `BAIYANGSHU WiFi Clock K4-03` |
| Upstream target | `Baiyangshu 1902 WiFi Clock K2-02` |
| MCU / module | ESP-12F; esptool identifies `ESP8266EX` |
| Crystal | 26 MHz |
| Flash | 4 MB = 4,194,304 bytes |
| Flash ID | `Manufacturer: 20`, `Device: 4016` |
| USB-UART | CP2102, header `3V3 / TXD / RXD / GND / +5V` |
| Windows port | `COM3` (re-check after replug or on another PC) |
| Tools | Windows 11, PowerShell, Python, Arduino IDE; esptool **5.3.1** |
| Repository | `E:\ChineseWallClock` |

The goal was to remove the factory firmware's always-on AP and use a maintainable open-source firmware. The factory serial log confirmed that it ran STA + SoftAP simultaneously. The replacement preserved the saved Wi-Fi configuration, closed the configuration AP and (per the maintainer) recovers after a network outage; long-term Wi-Fi stability was not separately measured.

## 2. Programming header: what was actually confirmed

“Left to right” below means the physical direction observed on **this** board with its photo. It is not a universal pin-1 definition for every K4-03.

| Observed position | Confirmation | Caution |
|---|---|---|
| 1 | **FLASH / GPIO0 confirmed** | Pull low, repower; esptool connected and two backups were read |
| 2 | **Not confirmed in this session** | Upstream K2-02 docs call it RST, but it was never wired or used |
| 3 | **GND confirmed** | Continuity to the clock's USB-A power ground; common-ground A/B/C tests passed |
| 4/5 | **Serial pair confirmed by communication** | Initial wiring produced no valid output; swapping the two wires worked. The text record does not finally assign which is MCU TX vs RX |
| 6 | **+5V confirmed usable for the clock** | The stable setup did not use it; the clock was powered from its own USB-A |

### TX/RX direction

The correct relationship is by signal direction, not by copying a pin number:

```text
clock TX (logs out)  ─────→ CP2102 RXD
clock RX (commands)  ←───── CP2102 TXD
```

Reading the factory log only proves the clock→PC direction. esptool identifying the chip and reading flash proved bidirectional communication.

## 3. Final power and wiring

```text
clock USB-A ─────────────── clock power
PC USB ──────────────────── CP2102 power

CP2102 GND ──────────────── board pin 3 GND
CP2102 RXD ←─────────────── board actual TX
CP2102 TXD ───────────────→ board actual RX

CP2102 +5V                 not connected
CP2102 3V3                 not connected
board pin 2                not connected; RST unused
download mode only:
board pin 1 FLASH/GPIO0 ─── board GND
```

The clock and CP2102 were separately powered and shared a common ground. The clock's USB-A ground does not remove the need for a common serial reference.

Avoid:

- connecting CP2102 `+5V` or `3V3` while the clock is on its own USB supply;
- treating the board `+5V` as UART logic level;
- assuming a `3V3` pin means the TXD level was measured — no independent TXD voltage measurement was kept.

## 4. Soldering fault and recovery

During soldering/wiring, the clock once showed no blue LED and no serial output, looking bricked. **No firmware write had been performed yet.** After cleaning the solder joints, removing external wiring, and powering only from the clock's USB-A, it recovered, reconnected to the original Wi-Fi and served the factory page.

Conclusion: the evidence supports a soldering/contact/boot-strap-state problem, not a corrupted factory image. No specific short was recorded, so do not claim a particular solder bridge as the proven cause.

Lessons:

1. Disconnect power and jumpers before soldering, cleaning or continuity tests.
2. Check both sides for bridges, cold joints, stray wire strands and pad edges.
3. A visual absence of a bridge does not prove a reliable connection.
4. Use the actual USB-A power ground as the reference, not the USB shell.
5. Continuity beeps alone are not a complete diagnosis; combine resistance, routing and live behaviour.
6. Strain-relieve the wires; intermittent contact during read/write is dangerous.
7. On an anomaly, power down and return to the minimal wiring; do not “rescue” by repeated power cycling or erasing.
8. No blue LED or no display does not prove a damaged chip; with GPIO0 held low the factory application is not supposed to run.

## 5. “GND connected, clock does not start” investigation

The clock once failed to start with CP2102 GND connected and recovered when it was removed, suggesting the programming GND was not connected or the board was intentionally locked. Later:

- pin 3 did have continuity to the USB-A power ground;
- CP2102 `+5V` was **not** connected during the anomaly, so “dual 5 V supply” is not a proven cause;
- three minimal tests passed:

| Test | Wiring | Result |
|---|---|---|
| A | Separate supplies, only GND connected | Clock boots normally |
| B | A + clock TX → CP2102 RXD | Factory serial log readable |
| C | B + CP2102 TXD → clock RX | Clock still boots; bidirectional communication works |

The common-ground scheme was correct; the original GND was not a dead pin. The exact electrical cause of the earlier anomaly was not determined; the focus moved to FLASH wiring and boot order.

The most effective method was to add **one wire at a time** and isolate variables, rather than connecting everything and guessing.

## 6. Serial and download mode

Windows enumerated `Silicon Labs CP210x USB to UART Bridge (COM3)`. Arduino Serial Monitor and Python miniterm both work, but only one program may own `COM3` at a time.

Factory log command:

```powershell
py -m serial.tools.miniterm COM3 115200
```

Exit with `Ctrl+]`.

After swapping TX/RX there was data but garbage; switching to `115200` produced clear factory ASCII. Some Chinese text remained garbled; that does not mean the serial link failed. `74880` is for the ESP8266 ROM boot messages, not the application log; the successful download-mode evidence is esptool connecting, not a saved ROM boot log.

To see the earliest boot messages, keep the CP2102 and serial monitor connected and power-cycle only the clock; unplugging the CP2102 removes the COM port.

Manual download mode:

```text
clock off → FLASH/GPIO0 to GND → clock on → run esptool
```

GPIO0 must be low at reset/boot; connecting it after the factory application is already running is not enough.

Successful identification:

```powershell
py -m esptool --chip esp8266 --port COM3 --baud 115200 `
  --before no-reset --after no-reset chip-id

py -m esptool --chip esp8266 --port COM3 --baud 115200 `
  --before no-reset --after no-reset flash-id
```

Observed: `Connected to ESP8266 on COM3`, `Chip type: ESP8266EX`, `Crystal frequency: 26MHz`, `Chip ID: <private>`, `Detected flash size: 4MB`. The chip ID/MAC suffix is a private hardware identifier and is not repeated in the public deployment record.

`Hard resetting via RTS pin...` is a tool message, not proof that the board reset. RTS was not wired; the commands used both `--before no-reset` and `--after no-reset`.

## 7. Factory backup

The private backup directory contains a verified full image and its hash/restore notes. Historical reads used:

```powershell
Set-Location <private-backup-dir>

py -m esptool --chip esp8266 --port COM3 --baud 115200 `
  --before no-reset --after no-reset `
  read-flash 0x000000 0x400000 K4-03_factory_1.bin

py -m esptool --chip esp8266 --port COM3 --baud 115200 `
  --before no-reset --after no-reset `
  read-flash 0x000000 0x400000 K4-03_factory_2.bin
```

Each read took about **382.9 seconds** at about **87.6 kbit/s**. Both files were 4,194,304 bytes and matched SHA-256 `59FC45E91B37DCAD5C4E60E90416E3351D303A7CB8739B791CBD999FDC0CA37E`.

Do not re-run the read command with the same filenames after flashing; it would overwrite the factory backup. The current private directory has `K4-03_FACTORY_VERIFIED.bin` with the same hash. The raw image is **not copied into the repository**; the maintainer keeps it privately. See [backup manifest](2026-07-23-k4-03-backup-manifest.md).

A successful two-read backup does not mean a restore was tested. **Restore remains NOT_RUN.**

## 8. Auto-brightness finding

After flashing, `Auto Brightness` worked but looked too dark. The upstream code:

```cpp
int brightness_level = 255 - config.brightness;
if (config.auto_brightness) {
    brightness_level = sensorBridghtness();
}
```

means auto mode **overrides** the manual `Brightness` value; it is not a baseline or offset. The mapping is approximately:

```text
sensorValue = analogRead(A0)
brightness_level = min(sensorValue / 4, 245)
```

The OE control is inverted: lower PWM is brighter, higher PWM is dimmer. No A0 readings were collected across lighting conditions, and the final core's PWM configuration was not recorded. The observed “too dark” result may be the upstream mapping, the light-sensor divider, or another K4-03 difference; the cause is not proven.

The maintainer's workaround was to disable auto brightness and use a fixed manual value; the fixed value/time was not recorded. Treat auto brightness as an **open usability issue**, not a passed feature.

## 9. Compatibility boundary

The upstream code defines GPIO15 (OE), GPIO12 (latch), GPIO14 (shift clock), GPIO13 (data), `A0` light sensor, and DS3231 over `Wire`. These are **code definitions**, not a full continuity measurement of the K4-03. The successful boot proves compatibility for the tested functions on this one unit, not for every K4-03 revision.

## 10. Checklist for the next unit

- [ ] Power off before soldering; inspect both sides for bridges, cold joints and strain.
- [ ] Verify pins with the real power ground and continuity; do not trust “left-to-right” from another board.
- [ ] Pin 1 FLASH and pin 3 GND confirmed; pin 2 unverified; photograph the final pin 4/5 orientation.
- [ ] Clock on its own USB supply; CP2102 only GND/RX/TX; +5V/3V3 unconnected.
- [ ] Add GND first, then receive, then transmit.
- [ ] A readable log proves only clock→PC; use esptool to prove bidirectional communication.
- [ ] GPIO0 low before repower for download; remove it before normal boot.
- [ ] Do not treat no LED/no display/RTS text as proof of damage or reset.
- [ ] Two full backups, matching size/hash; never overwrite the factory image.
- [ ] Do not publish the factory image or raw logs with saved Wi-Fi configuration.
- [ ] Flash success, functional test pass and restore test are three separate conclusions.

## 11. Related records

- [K4-03 deployment record](2026-07-23-k4-03-deployment.md) — build, flash, verification, boot and config.
- [Backup manifest](2026-07-23-k4-03-backup-manifest.md) — private backup and hash.
- [Hardware](../modules/hardware/README.md) — components, pins and cautions.
- [Deployment runbook](../modules/deployment/README.md) — repeatable procedure.
