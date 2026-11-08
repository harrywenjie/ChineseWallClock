# Fork Operations

This page records what the fork actually did after cloning the upstream project. The tracked source has no fork changes; fork commits are documentation only. The fork-local evidence is a mix of the ignored `temp/` build records and a user-provided Codex deployment log, curated in `docs/evidence/`.

Times below are workspace local time (UTC+12 in July 2026), reconstructed from the clone reflog, file modification times and the chat excerpt. They are not a formal session log; the deployment date is confirmed by the maintainer as **2026-07-23**.

## 1. Timeline

| Time | Operation | Evidence |
|---|---|---|
| 2026-01-27 20:03 UTC | Fork `harrywenjie/ChineseWallClock` created from `halacs/wallclock` | GitHub API metadata |
| 2026-07-23 (time not recorded) | Soldering/serial/GND troubleshooting; two full factory reads; backup verified | [hardware preparation](../evidence/2026-07-23-k4-03-hardware-preparation.md) |
| 2026-07-23 14:08:33 +12 | Local clone from the fork remote, HEAD `d55188e` | `.git` reflog, `git status` |
| 2026-07-23 ~14:22–14:26 | Downloaded Arduino CLI 0.35.3 and 1.5.1, Arduino IDE 2.3.2 source; created a local CLI config; installed ESP8266 core 3.1.2; extracted the bundled libraries; created a PDF virtualenv and rendered the schematic | `temp/downloads/`, `temp/toolchain/`, `temp/arduino-cli.yaml`, `temp/arduino-data/`, `temp/bundled/`, `temp/pdf-venv/`, `temp/pdfs/` |
| 2026-07-23 14:27 | `default` build | `temp/logs/build-default.log`, `temp/artifacts/default/` |
| 2026-07-23 14:29 | `repro2` build | `temp/artifacts/repro2/` |
| 2026-07-23 14:31–14:32 | Arduino IDE 2.3.2 source/CLI-options build; app-only image extracted at `0x1000` | `temp/build/ide232-cli/`, `temp/artifacts/ide232-cli/`, `temp/artifacts/default/app.bin` |
| 2026-07-23 14:34 | `canonical1` and `canonical2` deterministic builds | `temp/build/canonical1/`, `temp/build/canonical2/`, `temp/logs/build-canonical-ide232-cli.log` |
| 2026-07-23 ~14:34–14:52 | Pre-flash hash checks and approval; flash at `0x000000`; automatic + independent verification; first boot; config change; second boot (chat shell timestamp 14:52; exact times not recorded) | [K4-03 deployment record](../evidence/2026-07-23-k4-03-deployment.md) |
| 2026-11-08 | Documentation migration, deployment record and fresh local build verification | `docs/`, `docs/evidence/` |

## 2. Fork-local changes and setup

There are **no tracked firmware-source changes** in the fork: the build-time copied `.cpp` files match the upstream source after the generated `#line` directive, and the tracked source is still upstream `d55188e`. The fork-local work is documentation plus the uncommitted `temp/` build environment and the deployment itself.

- **Actual unit:** BAIYANGSHU **K4-03**, not the upstream K2-02. ESP8266EX, 26 MHz, 4 MB flash. The upstream K2-02 schematic was used as the wiring reference, but electrical equivalence is not proven. Physical preparation and pin confirmations: [hardware preparation](../evidence/2026-07-23-k4-03-hardware-preparation.md).
- **Factory backup:** full 4 MiB read twice; both 4,194,304-byte copies matched SHA-256 `59FC45E91B37DCAD5C4E60E90416E3351D303A7CB8739B791CBD999FDC0CA37E`. The backup is private, contains the saved Wi-Fi configuration (not just firmware), and must never enter Git. [Backup manifest](../evidence/2026-07-23-k4-03-backup-manifest.md).
- **Arduino CLI:** 0.35.3 was used; 1.5.1 was also downloaded. Both Windows 64-bit archives are in `temp/downloads/`.
- **Arduino IDE:** 2.3.2 source archive (`arduino-ide-2.3.2-source.zip`, 3,326,414 bytes) was downloaded, apparently to inspect or reproduce the IDE's build options.
- **ESP8266 core:** `esp8266:esp8266` **3.1.2**, installed under `temp/arduino-data/packages/esp8266/hardware/esp8266/3.1.2`.
- **Libraries:** `libraries/libraries.zip` extracted to `temp/bundled/libraries`. File-by-file comparison found **0 modified files** and 1 extra example file; the extracted tree is effectively the pinned snapshot.
- **Board manager URL:** `https://arduino.esp8266.com/stable/package_esp8266com_index.json`.
- **CLI config:** `temp/arduino-cli.yaml` redirects data/downloads/user directories into `temp/`.
- **Schematic:** PyMuPDF 1.26.3 and pypdf 6.1.1 rendered `KiCad/schematic.pdf` to 300 dpi page images and 600 dpi detail crops under `temp/pdfs/`. The schematic confirmed the K2-02 pin map and the GPIO15/OE early-enable risk.
- **Flashing tool:** esptool **5.3.1**, CP210x USB-UART on `COM3`, no RST/DTR/RTS connection; manual GPIO0 boot mode and `--before/after no-reset`.

## 3. Build results

All variants compiled the same upstream source with the same core and library versions. Five build directories were produced; all full images are **485,280 bytes**.

| Variant | Build directory | Custom build property | Full image | Notes |
|---|---|---|---|---|
| default | `temp/build/default` | none | 485,280 B | Direct Arduino CLI build |
| repro2 | `temp/build/repro2` | none | 485,280 B | Repeat build |
| ide232-cli | `temp/build/ide232-cli` | `build.warn_data_percentage=75` | 485,280 B | IDE-2.3.2-like options |
| canonical1 | `temp/build/canonical1` | `build.warn_data_percentage=75` | 485,280 B | Final deterministic build |
| canonical2 | `temp/build/canonical2` | `build.warn_data_percentage=75` | 485,280 B | Repeat with a different build path |

The final deterministic build fixed `SOURCE_DATE_EPOCH=1711661163` (the last firmware source commit time, 2024-03-28T22:26:03+01:00) and used Arduino CLI 0.35.3. Two independent clean builds produced byte-identical images: **485,280 bytes**, SHA-256 `5E4F281421DCE894FED3F03DD9599AF8A690218A85C70B6A5A5DB466748D3D1D`. This is the image that was flashed.

The size report is identical for the logged variants: RAM 37,404 / 80,192 (46 %), IRAM 62,551 / 65,536 (95 %), flash 443,980 / 1,048,576 (42 %). The build logs contain 14 `-Wwrite-strings` warnings and no errors.

`temp/artifacts/default/app.bin` (481,184 bytes) is the full image with its first 4,096 bytes removed; it starts with the app-image header `e9 05 02 40` at `0x0000` and corresponds to the `0x1000` app region. This is a derived image, not a separate firmware. The flashed image was the combined `canonical1/ChineseWallClock.ino.bin`: eboot at `0x000000`, application at `0x001000`, no separate filesystem image.

No variant matched the v1.1 release size (485,248 bytes). The 32-byte difference is recorded as **UNKNOWN** in `docs/VALIDATION.md`; it was not resolved.

## 4. Deployment record

The deployment is recorded in detail in [2026-07-23 K4-03 deployment](../evidence/2026-07-23-k4-03-deployment.md). Summary:

- The pre-flash checks re-verified the private factory backup hash and the firmware hash, confirmed the bootloader connection, and used no full-chip erase.
- The image was written at `0x000000` with esptool 5.3.1, `--before no-reset --after no-reset`, `--flash-mode keep --flash-freq keep --flash-size keep`, at 115200 baud.
- esptool reported `Hash of data verified`; an independent `verify-flash` reported `Verification successful (digest matched)`.
- First boot: LittleFS mounted, no config file, defaults loaded; the preserved SDK Wi-Fi credentials reconnected the device; the web UI was reachable.
- The portal then saved `Pacific/Auckland`, `nz.pool.ntp.org`, empty syslog and the display options; the second boot read the config back and used `REASON_SOFT_RESTART`.
- Only `0x000000–0x076FFF` was written, so the SDK Wi-Fi parameter region was preserved.
- Human feedback: Wi-Fi was reused, the configuration AP is closed, and the clock automatically recovers after a network outage. Auto brightness was too dark; the maintainer switched to fixed manual brightness.

This is a **software/deployment pass**, not a full hardware-compatibility qualification. Display segment details and the auto-brightness cause remain partial.

## 5. What is still missing

- Detailed display segment/ghosting and second-LED results. The maintainer reported the device looked normal, but no detailed test record was supplied.
- The exact auto-brightness cause and A0/PWM measurements. The maintainer reports network-loss recovery, but the RTC-only path was not isolated.
- The raw Codex chat logs are not committed; the curated records are the public source. Private values (MAC, SSID, LAN IP, AP suffix, backup path) are deliberately omitted.
- OTA upload, web-UI firmware upload, watchdog under network loss, power-cycle persistence, corrupt-config recovery and long-term Wi-Fi stability remain unverified.
- The K2-02 vs K4-03 electrical differences are not documented; only the K2-02 schematic and the actual K4-03 boot behaviour are available.

## 6. Relation to upstream

The fork's tracked source is upstream `d55188e`; documentation commits do not change firmware. Upstream has newer commits (pushed 2026-09-05), not merged. The 2024 releases, factory dump and screenshots are upstream artifacts, not fork operations. The actual unit is a K4-03, so the upstream K2-02 factory image is not its recovery image. Do not present the 2026-07-23 K4-03 deployment as an upstream release or the upstream screenshots as evidence of this unit.

## 7. Preserved evidence

- [2026-07-23 K4-03 deployment](../evidence/2026-07-23-k4-03-deployment.md) — actual build, backup, flash, verification, boot logs and config.
- [2026-07-23 hardware preparation](../evidence/2026-07-23-k4-03-hardware-preparation.md) — soldering, serial/GND troubleshooting, pin confirmations, auto-brightness finding.
- [2026-07-23 backup manifest](../evidence/2026-07-23-k4-03-backup-manifest.md) — private full-flash backup and restore plan (raw image not in repo).
- [2026-07-23 fork build](../evidence/2026-07-23-fork-build/README.md) — tool versions, build variants, logs, config/script copies, artifact hashes.
- [2026-11-08 local build](../evidence/2026-11-08-local-build.md) — independent compile verification.
- [Validation](../VALIDATION.md) — what the evidence does and does not qualify.
