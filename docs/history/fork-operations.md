# Fork Operations

This page records what the fork actually did after cloning the upstream project. The fork has no commits or pushes; the evidence is a set of uncommitted files that were kept in `temp/` and are now copied to `docs/evidence/2026-07-23-fork-build/`.

Times below are workspace local time (UTC+12 in July 2026), reconstructed from the clone reflog and file modification times. They are not a formal session log.

## 1. Timeline

| Time | Operation | Evidence |
|---|---|---|
| 2026-01-27 20:03 UTC | Fork `harrywenjie/ChineseWallClock` created from `halacs/wallclock` | GitHub API metadata |
| 2026-07-23 14:08:33 +12 | Local clone from the fork remote, HEAD `d55188e` | `.git` reflog, `git status` |
| 2026-07-23 ~14:22–14:26 | Downloaded Arduino CLI 0.35.3 and 1.5.1, Arduino IDE 2.3.2 source; created a local CLI config; installed ESP8266 core 3.1.2; extracted the bundled libraries; created a PDF virtualenv and rendered the schematic | `temp/downloads/`, `temp/toolchain/`, `temp/arduino-cli.yaml`, `temp/arduino-data/`, `temp/bundled/`, `temp/pdf-venv/`, `temp/pdfs/` |
| 2026-07-23 14:27 | `default` build | `temp/logs/build-default.log`, `temp/artifacts/default/` |
| 2026-07-23 14:29 | `repro2` build | `temp/artifacts/repro2/` |
| 2026-07-23 14:31–14:32 | Arduino IDE 2.3.2 source/CLI-options build; app-only image extracted at `0x1000` | `temp/build/ide232-cli/`, `temp/artifacts/ide232-cli/`, `temp/artifacts/default/app.bin` |
| 2026-07-23 14:34 | `canonical1` and `canonical2` builds; final build log | `temp/build/canonical1/`, `temp/build/canonical2/`, `temp/logs/build-canonical-ide232-cli.log` |
| 2026-11-08 | Documentation migration; fresh local build verification | `docs/`, `docs/evidence/2026-11-08-local-build.md` |

## 2. Fork-local changes and setup

There are **no tracked source changes** in the fork: `git status` is clean and the build-time copied `.cpp` files match the upstream source after the generated `#line` directive. The fork-local changes were confined to the ignored `temp/` workspace: a local Arduino CLI configuration, an installed ESP8266 core, extracted pinned libraries, a PDF virtualenv and several build variants. The reported physical deployment has no recorded date/unit/image/offset; see §5.

- **Arduino CLI:** 0.35.3 was used; 1.5.1 was also downloaded. Both Windows 64-bit archives are in `temp/downloads/`.
- **Arduino IDE:** 2.3.2 source archive (`arduino-ide-2.3.2-source.zip`, 3,326,414 bytes) was downloaded, apparently to inspect or reproduce the IDE's build options.
- **ESP8266 core:** `esp8266:esp8266` **3.1.2**, installed under `temp/arduino-data/packages/esp8266/hardware/esp8266/3.1.2`.
- **Libraries:** `libraries/libraries.zip` extracted to `temp/bundled/libraries`. File-by-file comparison against the zip found **0 modified files** and 1 extra example file; the extracted tree is effectively the pinned snapshot.
- **Board manager URL:** `https://arduino.esp8266.com/stable/package_esp8266com_index.json`.
- **CLI config:** `temp/arduino-cli.yaml` redirects data/downloads/user directories into `temp/`.
- **Schematic:** a Python virtualenv with PyMuPDF 1.26.3 and pypdf 6.1.1 rendered `KiCad/schematic.pdf` to 300 dpi page images and 600 dpi detail crops under `temp/pdfs/`.

## 3. Build results

All variants compiled the same upstream source with the same core and library versions. Five build directories were produced; all full images are **485,280 bytes**.

| Variant | Build directory | Custom build property | Full image | Notes |
|---|---|---|---|---|
| default | `temp/build/default` | none | 485,280 B | Direct Arduino CLI build |
| repro2 | `temp/build/repro2` | none | 485,280 B | Repeat build |
| ide232-cli | `temp/build/ide232-cli` | `build.warn_data_percentage=75` | 485,280 B | IDE-2.3.2-like options |
| canonical1 | `temp/build/canonical1` | `build.warn_data_percentage=75` | 485,280 B | Final canonical variant |
| canonical2 | `temp/build/canonical2` | `build.warn_data_percentage=75` | 485,280 B | Repeat with a different build path |

The size report is identical for the logged variants: RAM 37,404 / 80,192 (46 %), IRAM 62,551 / 65,536 (95 %), flash 443,980 / 1,048,576 (42 %). The build logs contain 14 `-Wwrite-strings` warnings and no errors.

`temp/artifacts/default/app.bin` (481,184 bytes) is the full image with its first 4,096 bytes removed; it starts with the app-image header `e9 05 02 40` at `0x0000` and corresponds to the `0x1000` app region. This is a derived image, not a separate firmware.

No variant matched the v1.1 release size (485,248 bytes). The 32-byte difference is recorded as **UNKNOWN** in `docs/VALIDATION.md`; it was not resolved in this session.

## 4. What was not found

- No `esptool` flash/read log for the fork, no serial boot log, no deployment date or unit record.
- No fork-specific source modification: the build-time copied `.cpp` files match the current source after the generated `#line` directive, and `git status` is clean.
- No commit or push of the build setup: `temp/` is ignored, and the fork remote is still at `d55188e`.
- No evidence that a particular build variant was flashed. The `app.bin` extraction suggests an interest in the app-only form, but it is not proof of a flash.

## 5. Deployment gap

The maintainer reports that the fork was deployed on a real WiFi clock. The repository and the preserved temp set do **not** contain the deployment specifics. To close the gap, record at minimum:

1. date/time and physical unit;
2. full per-unit factory backup length and SHA-256;
3. firmware image (commit, form, offset, SHA-256);
4. flash tool/version and the exact command;
5. serial boot log;
6. effective configuration (device name, NTP, timezone, syslog, brightness, toggles);
7. post-flash observations and any rollback.

Use the [deployment record template](../modules/deployment/README.md#record-template) and keep private network identifiers out of the public repository.

## 6. Relation to upstream

The fork's tracked history is upstream history at `d55188e`. Upstream has newer commits (pushed 2026-09-05); the fork has not merged them. The 2024 releases, factory dump and screenshots are upstream artifacts, not fork operations. Do not present the 2026-07-23 build as an upstream release or the upstream screenshots as fork deployment evidence.

## 7. Preserved evidence

- [2026-07-23 fork build](../evidence/2026-07-23-fork-build/README.md) — tool versions, build variants, logs, config/script copies, artifact hashes.
- [2026-11-08 local build](../evidence/2026-11-08-local-build.md) — current compile verification.
- [Validation](../VALIDATION.md) — what the evidence does and does not qualify.
