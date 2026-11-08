# Deployment Runbook

This is the reproducible procedure for putting this firmware on a similar Baiyangshu clock, plus the record of the actual **K4-03** deployment on 2026-07-23. It is assembled from the inherited upstream hardware evidence, the fork build records and the [redacted deployment record](../../evidence/2026-07-23-k4-03-deployment.md).

The goal is a repeatable deployment with a per-unit backup and a complete record, not just a successful flash. Private identifiers (MAC, SSID, LAN IP, AP suffix, backup path) are deliberately omitted; keep them in the private deployment note.

## 1. Pre-flight

- Confirm the clock model and board marking. The upstream target is **K2-02**; the actual fork unit is **K4-03**. Both use an ESP-12F/ESP8266EX, four 74HC595D shift registers and a DS3231, but do not assume electrical equivalence. Photograph the board.
- Read [hardware](../hardware/README.md), [build and flash](../build-and-flash/README.md) and [factory firmware](../factory-firmware/README.md).
- Prepare a **3.3 V USB-TTL adapter**, dupont leads, a soldering iron/header if the 6-pin pads are unpopulated, the clock's own power supply, and a computer with `esptool` and the Arduino toolchain.
- Prepare storage for backups and logs. Keep private identifiers (SSID, LAN addresses, MAC, AP suffix, syslog host, backup path) out of the public repository.
- Do not start by flashing the clock. First do a **read-only backup**, verify it, and only then write.

### Recorded deployment (2026-07-23, K4-03)

| Item | Actual value |
|---|---|
| Unit | BAIYANGSHU **K4-03**, ESP8266EX, 26 MHz, 4 MB |
| UART | CP210x on `COM3`; only GND/TX/RX; clock on its own USB-A supply |
| Boot mode | GPIO0/`FLASH` to GND, then repower; no RST/DTR/RTS |
| Factory backup | Full 4 MiB, **4,194,304 bytes**, two copies, SHA-256 `59FC45E91B37DCAD5C4E60E90416E3351D303A7CB8739B791CBD999FDC0CA37E` |
| Build | Arduino CLI 0.35.3, core 3.1.2, pinned libraries, `SOURCE_DATE_EPOCH=1711661163` |
| Image | `canonical1/ChineseWallClock.ino.bin`, **485,280 bytes**, SHA-256 `5E4F281421DCE894FED3F03DD9599AF8A690218A85C70B6A5A5DB466748D3D1D` |
| Flash | esptool 5.3.1, `0x000000`, `--before/after no-reset`, `--flash-*-keep`, no full erase |
| Result | `Hash of data verified`; independent `verify-flash` passed; first boot, config, Wi-Fi reuse, AP closure and network-loss recovery passed; auto brightness was too dark, so fixed brightness is used |

The full record, including redacted boot logs and the exact commands, is [2026-07-23 K4-03 deployment](../../evidence/2026-07-23-k4-03-deployment.md). Physical preparation and serial troubleshooting are in [hardware preparation](../../evidence/2026-07-23-k4-03-hardware-preparation.md); the private backup policy is in [backup manifest](../../evidence/2026-07-23-k4-03-backup-manifest.md).

## 2. Record template

<a id="record-template"></a>

Copy this into a private deployment note (and, if the maintainer approves, a dated `docs/evidence/` page with private fields redacted):

```text
Deployment date/time:
Clock model / board marking:
Unit identifier (private):
ESP chip / flash size / MAC (private):
Factory backup file:
Factory backup length (must be full flash):
Factory backup SHA-256:
Firmware source: commit / release
Firmware image file:
Firmware image form: full (0x0000) / app-only (0x1000)
Firmware SHA-256:
Build tool and version:
Flash tool and version:
Flash offset and command:
Serial port / baud:
Boot log captured:
Device name:
NTP server:
Timezone (IANA):
Syslog server (private):
Brightness / auto brightness:
Second blinking / clever / leading zeros:
Post-flash checks (display, time, DST, WiFi, OTA, power cycle):
Issues / rollback:
```

Record the image **form and offset**, not just the filename. Two files can have the same name and different offsets.

<a id="3-phase-1-full-factory-backup"></a>

## 3. Phase 1 — full factory backup

1. Open the clock and identify the 6-pin header. Verify the pin order against the [programming-interface photo](../../images/programming_interface.jpg) and the schematic; do not trust label order alone.
2. Connect a 3.3 V USB-TTL adapter: `GND`, `TXD0`/`RXD0` crossed, and the appropriate boot-mode pad. Do not connect the programmer's 5 V supply until the board's power path is understood.
3. Enter the ESP8266 bootloader (commonly `FLASH` low + pulse `RST`; verify on this board).
4. Detect the chip and flash size before reading:

   ```text
   esptool --port <PORT> flash_id
   ```

5. Read the **full** flash, not the upstream 4,000,000-byte prefix:

   ```text
   esptool --port <PORT> --baud 115200 read_flash 0x000000 0x400000 factory-full-4MiB.bin
   ```

   `0x400000` = 4,194,304 bytes. Adjust only if `flash_id` reports a different size, and record the actual size.
6. Verify the file length and hash:

   ```text
   Get-FileHash factory-full-4MiB.bin -Algorithm SHA256
   ```

   On Linux/macOS use `sha256sum`. Keep the backup and hash offline; a backup that is only on the bench machine is not a backup.
7. Do not proceed until the length, chip, flash size and hash are recorded.

For the actual K4-03, two full reads both produced **4,194,304 bytes** with SHA-256 `59FC45E91B37DCAD5C4E60E90416E3351D303A7CB8739B791CBD999FDC0CA37E`. Keep that backup private: it contains the saved Wi-Fi configuration, not just firmware.

The inherited `factory_firmware/image4M.bin` is **not** a substitute for this step: it is 4,000,000 bytes, from the upstream K2-02 author's device, and leaves the last 194,304 bytes of a 4 MiB flash unread. See [factory firmware](../factory-firmware/README.md).

## 4. Phase 2 — build or select the image

- Prefer a build from the current source with the pinned toolchain/libraries. Follow [build and flash](../build-and-flash/README.md#arduino-cli).
- If using an inherited release, verify its size/hash against [validation](../../VALIDATION.md#release-rebuild). Release v1.1 is a full image, not an app-only image.
- Record the source commit and the image SHA-256. Do not rely on “the latest build” without a hash.
- Decide the image form: full image at `0x0000`, or app-only at `0x1000` only if the bootloader is known good. When in doubt, use the full image at `0x0000`.

## 5. Phase 3 — flash

Template only; verify the tool's options and the board's flash mode/frequency/size:

```text
esptool --port <PORT> --baud 115200 write_flash \
  --flash_mode dio --flash_freq 40m --flash_size 4MB \
  0x0000 <full-image.bin>
```

For an app-only image, change the offset to `0x1000` and the file; never use the full-image offset for an app-only file. Capture the full esptool output and the serial boot log at 115200.

The actual K4-03 write used `--flash-mode keep --flash-freq keep --flash-size keep`, `0x000000`, the 485,280-byte combined image, and no full-chip erase. esptool erased only `0x000000–0x076FFF`, wrote 485,280 bytes, reported `Hash of data verified`, and the independent `verify-flash` reported `Verification successful (digest matched)`.

If the board does not enter the bootloader, stop and re-check wiring/power rather than retrying with a different offset.

## 6. Phase 4 — first boot and configuration

1. Power the clock normally and open the serial console at **115200**. Expect `[INFO] Booting`, the configuration dump, AP name/password, NTP result, WiFi result and reset reason.
2. On first boot, connect to the AP `halclock<chipid>` with password `password` (or the configured values if a config already exists).
3. Open the portal and fill in:
   - device name (for example `Kitchen clock`; this becomes the page title);
   - NTP server (use a reachable server; the default is `hu.pool.ntp.org`);
   - timezone as an exact IANA name (for example `Europe/Budapest`);
   - syslog server (optional; a private LAN collector);
   - brightness and the four checkboxes;
   - WiFi SSID/password.
4. Save. The firmware writes `/halclock.conf` and reboots. Reconnect on the station network; the portal should still be reachable at the device IP.
5. Record the effective configuration and the device IP in the private deployment note. Do not publish the SSID, LAN addresses, MAC or syslog host.

## 7. Phase 5 — verification

- **Display:** all segments, `HH:MM`, no ghosting; leading-zero and clever settings; second LEDs steady/blinking; brightness 1/128/255; auto brightness response. On the actual K4-03 auto brightness was too dark; fixed brightness is the known workaround.
- **Time:** NTP success in serial; correct local time and DST; reboot with NTP blocked to exercise the DS3231 fallback; power-cycle with the RTC battery.
- **Network:** AP name/password, portal title, station connection, web page reachable, hostname/IP.
- **OTA:** Arduino IDE network port appears; password is the AP name; a test upload succeeds (do not use the broken web-UI upload).
- **Persistence:** save each field, reboot, confirm it survives — specifically test `clever` (known defect) and leading zeros.
- **Recovery:** corrupt `/halclock.conf` on a spare unit and record what happens; currently the code may not apply defaults.
- **Power:** unplug/replug; confirm the clock recovers without a serial connection.

## 8. Phase 6 — closeout

1. Fill the record template.
2. Store the full factory backup, firmware image, logs and hashes together.
3. Update `docs/DEVELOPMENT.md` §1/§5 and add a dated evidence page (private fields redacted).
4. State clearly what was observed on the device and what was only compiled.
5. Keep the previous working image and backup until the new deployment has run for a reasonable period.

## 9. Rollback

1. Power off, enter the bootloader, and write the **per-unit** full backup at `0x000000` with the same flash mode/frequency/size recorded at backup time.
2. For the actual K4-03, first re-check the private backup SHA-256 `59FC45E91B37DCAD5C4E60E90416E3351D303A7CB8739B791CBD999FDC0CA37E` and size 4,194,304 bytes.
3. Verify the write and boot; capture the serial log.
4. Do not restore the inherited upstream 4,000,000-byte dump to a different unit; it is incomplete and K2-02-specific.

## 10. Known risks

- The web-UI firmware upload is reported broken; serial and OTA are the known paths.
- The AP password is hard-coded (`password`), the OTA password is the AP name, and the web UI has no authentication.
- IRAM is at 95 %; a new build may fail or behave differently if code grows.
- K4-03 risks: GPIO15 is a low boot strap and the active-low OE may enable display outputs briefly at reset; the display mapping is hard-coded; auto brightness was too dark on the actual unit (use fixed brightness until A0/PWM are measured); DS3231 detection is not logged; the blue LED is not controlled.
- The K4-03 factory backup contains the saved Wi-Fi configuration. Never commit, upload or share it; restore only from the per-unit backup.
- The upstream screenshots show a working deployment of the upstream firmware, but they are not evidence of this fork's unit or configuration. The actual fork record is the [K4-03 deployment](../../evidence/2026-07-23-k4-03-deployment.md).
