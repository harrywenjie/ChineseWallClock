# Factory Firmware and Original UI

This page records the inherited upstream factory-firmware backup, the actual K4-03 per-unit backup, how the upstream image was extracted, and what the original firmware's UI did. The upstream image is **not** a K4-03 recovery image.

## 1. The backup file

`factory_firmware/image4M.bin` is a flash dump of the original clock:

| Property | Value |
|---|---|
| Size | **4,000,000 bytes** (`0x3D0900`) |
| SHA-256 | `577F86DE790229E70824DB782B48BF33701905760CB49BEA1E94FB0CABED0447` |
| Origin | Upstream author's device, added in the 2024-03-23 documentation commit |
| Form | Partial full-flash dump, not an Arduino app image |

The filename is approximate. A full 4 MiB flash is `0x400000` = 4,194,304 bytes; this file stops 194,304 bytes short. Do not treat it as a complete per-unit backup, and do not restore it to a different clock.

### Actual K4-03 per-unit backup (this fork)

The actual fork unit is a **K4-03**, not the upstream K2-02. Its factory flash was read twice before flashing:

| Property | Value |
|---|---|
| Size (each) | **4,194,304 bytes** (`0x400000`) |
| SHA-256 (both copies) | `59FC45E91B37DCAD5C4E60E90416E3351D303A7CB8739B791CBD999FDC0CA37E` |
| Copies | `K4-03_factory_1.bin`, `K4-03_factory_2.bin` in a private backup directory |
| Verification | Both reads matched; recorded as `BACKUP VERIFIED` |

The backup contains the ESP8266 SDK Wi-Fi credentials. It must never be committed, copied into `temp/`, attached to an issue or shared publicly. Restore only from this per-unit backup, not from `factory_firmware/image4M.bin`.

Restore is a full 4 MB write at `0x000000`:

```powershell
py -m esptool --chip esp8266 --port COM3 --baud 115200 `
  --before no-reset --after no-reset `
  write-flash 0x000000 `
  <private-backup-dir>\K4-03_factory_1.bin
```

Do not run it without a fresh hash check and explicit approval. See [the deployment record](../../evidence/2026-07-23-k4-03-deployment.md).

## 2. How it was extracted

The upstream screenshot `docs/images/factory_firmware/download_factory_firmware.png` records the command (original filename `Screenshot from 2024-03-14 22-12-57.png`):

```text
esptool --port /dev/ttyUSB0 read_flash 0x00000 0x3D0900 image4M.bin
```

It shows `esptool.py v4.7.0` reading 4,000,000 bytes from an ESP8266EX (26 MHz) in 360.4 seconds. The command reads `0x3D0900`, not `0x400000`; that is the incomplete-length caveat. A correct per-unit backup uses the full flash size reported by `esptool flash_id` (normally `0x400000` for 4 MiB).

![Factory firmware extraction](../../images/factory_firmware/download_factory_firmware.png)

## 3. Entropy analysis

Entropy plot of the dump (`docs/images/factory_firmware/binwalk_entropy.png`):

- High entropy in roughly the first 0–0.5 MB (firmware/application region).
- A narrow high-entropy region around 1.0 MB (likely a filesystem).
- Near-zero entropy for most of the remaining dump (erased flash).

This is a sanity check that the dump contains real content; it is not a security analysis or a restore procedure.

![Entropy analysis](../../images/factory_firmware/binwalk_entropy.png)

## 4. Original firmware UI

The inherited screenshots show the factory web UI:

| Screen | Image | What it records |
|---|---|---|
| Main menu | [main.png](../../images/factory_firmware/main.png) | Six setup entries, “BRIGHTEN UP YOUR TIME!” |
| Clock base | [base.png](../../images/factory_firmware/base.png) | First-zero, second-dot flash, 24 h, clever `1`, temperature revision |
| Light PWM | [brightness.png](../../images/factory_firmware/brightness.png) | LED level, auto-light off |
| Auto power | [auto_on-off.png](../../images/factory_firmware/auto_on-off.png) | Auto power off; example 7:00–22:00 |
| NTP | [ntp.png](../../images/factory_firmware/ntp.png) | LAN NTP, fixed `UTC +01:00 CET`, DST off |
| WiFi | [wifi.png](../../images/factory_firmware/wifi.png) | SSID/password, scan/list |
| Load defaults | [load_factory_defaults.png](../../images/factory_firmware/load_factory_defaults.png) | Restore all / retain WiFi / set from mobile |

The exact network identifiers, addresses and MAC shown in these upstream images are deliberately not transcribed here.

## 5. Why replace it

The upstream README's rationale:

- The factory firmware keeps a WiFi access point on.
- It has no automatic daylight-saving support (the NTP screen shows a fixed UTC+1 offset with DST off).
- The replacement is open source and can be extended.

The replacement adds a web UI, NTP + DS3231 timekeeping with timezone/DST, optional second-LED blinking, leading-zero/clever display settings, manual and automatic brightness, Arduino OTA and syslog. The current feature set and open gaps are in [firmware](../firmware/README.md) and `docs/DEVELOPMENT.md` §5.

## 6. Restore caveats

- The upstream dump is a **partial full-flash** image: writing it at `0x000000` restores 4,000,000 bytes and leaves the tail untouched. That may be enough if the tail is erased, but it is not a verified full restore.
- The upstream dump came from the K2-02 author's device. Restoring it to a K4-03 can clone the wrong MAC/calibration/configuration and is not a per-unit recovery.
- The actual K4-03 backup is complete (4,194,304 bytes) and is the only valid per-unit restore for this fork's clock. Its hash is in §1; protect it because it contains Wi-Fi credentials.
- The factory image is not an Arduino app-only image. Do not write it at `0x1000`.
- Before any restore, re-check the private backup hash and size. Do not erase the chip first; the full-image write covers the flash.
- Restore has not been verified in this workspace; treat it as **NOT_RUN** until a device test is recorded.

## 7. Provenance

Inherited upstream artifacts plus the K4-03 backup; no fork factory-firmware change. The 2024-03-14 screenshot is the upstream extraction session, not the fork deployment date. Actual K4-03 deployment: [2026-07-23 K4-03](../../evidence/2026-07-23-k4-03-deployment.md).
