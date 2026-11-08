# Factory Firmware and Original UI

This page records the inherited factory-firmware backup, how it was extracted, and what the original firmware's UI did. It is **upstream evidence**, not a fork deployment record.

## 1. The backup file

`factory_firmware/image4M.bin` is a flash dump of the original clock:

| Property | Value |
|---|---|
| Size | **4,000,000 bytes** (`0x3D0900`) |
| SHA-256 | `577F86DE790229E70824DB782B48BF33701905760CB49BEA1E94FB0CABED0447` |
| Origin | Upstream author's device, added in the 2024-03-23 documentation commit |
| Form | Partial full-flash dump, not an Arduino app image |

The filename is approximate. A full 4 MiB flash is `0x400000` = 4,194,304 bytes; this file stops 194,304 bytes short. Do not treat it as a complete per-unit backup, and do not restore it to a different clock.

## 2. How it was extracted

The upstream screenshot `docs/images/factory_firmware/download_factory_firmware.png` records the command and session (the original filename in the initial commit was `Screenshot from 2024-03-14 22-12-57.png`):

```text
esptool --port /dev/ttyUSB0 read_flash 0x00000 0x3D0900 image4M.bin
```

Observed in the screenshot:

- `esptool.py v4.7.0`, Linux host, port `/dev/ttyUSB0`.
- Chip detected as `ESP8266EX`, 26 MHz crystal, WiFi feature.
- Read `4,000,000` bytes at `0x00000000` in 360.4 seconds (88.8 kbit/s).
- Hard reset via RTS after the read.

The command reads `0x3D0900` bytes, not `0x400000`. That is the source of the incomplete-length caveat. A correct per-unit backup for future deployment must read the full flash size reported by `esptool flash_id` (normally `0x400000` for a 4 MiB part).

![Factory firmware extraction](../../images/factory_firmware/download_factory_firmware.png)

## 3. Entropy analysis

`docs/images/factory_firmware/binwalk_entropy.png` is an entropy plot of the dump:

- High entropy in roughly the first 0–0.5 MB (firmware/application region).
- A narrow high-entropy region around 1.0 MB (likely a filesystem).
- Near-zero entropy for most of the remaining dump (erased flash).

This is a sanity check that the dump contains real content; it is not a security analysis or a restore procedure.

![Entropy analysis](../../images/factory_firmware/binwalk_entropy.png)

## 4. Original firmware UI

The inherited screenshots show the factory web UI:

| Screen | Image | What it records |
|---|---|---|
| Main menu | [main.png](../../images/factory_firmware/main.png) | “BAIYANGSHU WIFI LED CLOCK”, six setup entries, “BRIGHTEN UP YOUR TIME!” |
| Clock base setup | [base.png](../../images/factory_firmware/base.png) | View setup, first-zero mode, second-dot flash, 24 h format, clever `1` format, temperature revision |
| Light PWM | [brightness.png](../../images/factory_firmware/brightness.png) | LED light level (example: Level 1), auto-light off |
| Auto power | [auto_on-off.png](../../images/factory_firmware/auto_on-off.png) | Auto power off; example on 7:00, off 22:00 |
| NTP setup | [ntp.png](../../images/factory_firmware/ntp.png) | LAN NTP server field, fixed `UTC +01:00 CET`, DST mode off |
| WiFi setup | [wifi.png](../../images/factory_firmware/wifi.png) | SSID/password fields, scan and list; the page footer shows a LAN IP |
| Load defaults | [load_factory_defaults.png](../../images/factory_firmware/load_factory_defaults.png) | Restore all factory settings, restore settings while retaining WiFi, set time from mobile |

The exact network identifiers, addresses and MAC shown in these upstream images are deliberately not transcribed here.

## 5. Why replace it

The upstream README's rationale:

- The factory firmware keeps a WiFi access point on.
- It has no automatic daylight-saving support (the NTP screen shows a fixed UTC+1 offset with DST off).
- The replacement is open source and can be extended.

The replacement adds a web UI, NTP + DS3231 timekeeping with timezone/DST, optional second-LED blinking, leading-zero/clever display settings, manual and automatic brightness, Arduino OTA and syslog. The current feature set and open gaps are in [firmware](../firmware/README.md) and `docs/DEVELOPMENT.md` §5.

## 6. Restore caveats

- The dump is a **partial full-flash** image: writing it at `0x000000` restores 4,000,000 bytes and leaves the tail untouched. That may be enough if the tail is erased, but it is not a verified full restore.
- The dump came from the upstream author's device. Restoring it to another unit can clone the wrong MAC/calibration/configuration and is not a per-unit recovery.
- The factory image is not an Arduino app-only image. Do not write it at `0x1000`.
- Before any restore, make a full per-unit backup with the procedure in [deployment](../deployment/README.md#3-phase-1-full-factory-backup).
- Restore has not been verified in this workspace; treat it as **NOT_RUN** until a device test is recorded.

## 7. Provenance

This page documents inherited upstream artifacts. The fork has no recorded factory-firmware modification. The 2024-03-14 screenshot timestamp is the upstream extraction session, not a fork deployment date.
