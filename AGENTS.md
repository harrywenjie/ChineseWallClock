# ChineseWallClock Project Instructions

This file holds project-specific, stable constraints. Generic DSH documentation, session and Git rules live in the applicable global `AGENTS.md` and skills; do not copy them here.

## What this repository is

- A fork of [`halacs/wallclock`](https://github.com/halacs/wallclock), maintained as `harrywenjie/ChineseWallClock`.
- Arduino/ESP8266 replacement firmware for the **Baiyangshu 1902 Wifi Clock K2 02** (four-digit LED wall clock).
- The tracked history is upstream history: HEAD `d55188e` (2025-07-25). As of 2026-11-08 the fork has no commits or pushes of its own.
- Treat `releases/`, `factory_firmware/`, `docs/images/`, `docs/display/`, `docs/datasheets/`, and `KiCad/` as inherited upstream artifacts unless a record explicitly says otherwise.
- Fork-local work was uncommitted and kept in `temp/`. The 2026-07-23 build session is preserved in `docs/evidence/2026-07-23-fork-build/`.
- A real fork deployment is reported by the maintainer, but its details are **待核实** (to be verified); see `docs/DEVELOPMENT.md` §5. Do not invent dates, images, flash offsets, or test results.

## Reading card

| Task | Read first | Then |
|---|---|---|
| Any round | `README.md`, `docs/DEVELOPMENT.md` §1–2, §5, §7 | The task's direct contract below |
| Firmware behaviour | `docs/ENGINEERING_DESIGN.md`, `docs/modules/firmware/README.md` | The focused firmware topic file |
| Build or flash | `docs/modules/build-and-flash/README.md` | `docs/evidence/2026-11-08-local-build.md` |
| Deploy a similar clock | `docs/modules/deployment/README.md` | `docs/modules/hardware/README.md`, `docs/modules/factory-firmware/README.md` |
| Hardware or schematic | `docs/modules/hardware/README.md` | The linked datasheet or `KiCad/schematic.pdf` |
| Historical or provenance question | `docs/history/README.md` | `docs/history/fork-operations.md` |
| Documentation maintenance | `AGENTS.md` (this file), `docs/DEVELOPMENT.md` §4 | `docs/maintenance/` records |

Do not load all module docs by default. Follow the direct dependency first; load history/evidence only when provenance, audit, or a conflict requires it.

## Hardware and firmware constraints

- Target board: **ESP-12F** (ESP8266), 4 × **74HC595D** shift registers, **DS3231SM** RTC on I2C, and an environment-light sensor on `A0`.
- Arduino target: `esp8266:esp8266:d1_mini` (Wemos D1 mini / ESP-12F), ESP8266 core **3.1.2** (verified 2026-07-23 and 2026-11-08). The original author used Arduino IDE 2.3.2 on Ubuntu 22.04.4; that is not the only supported environment.
- Shift-register pins: `SR_OE` GPIO15, `SR_RCLK` GPIO12, `SR_SRCLK` GPIO14, `SR_SER` GPIO13. RTC uses the ESP8266 default `Wire` pins (GPIO4/5 unless the schematic says otherwise). Confirm against `KiCad/schematic.pdf` before rewiring.
- Runtime configuration is LittleFS JSON at `/halclock.conf`; the `Config` struct and defaults live in `myConfig.h`. Saving from the web UI calls `wm.reboot()`.
- Network identity: AP/hostname `halclock` + uppercase chip ID; AP password is the hard-coded `password`; OTA password is the AP name. The web UI has no authentication.
- `ENABLE_OTA` is a compile-time define in `myConfig.h`. Removing it excludes OTA from the build; it does not add web-UI authentication.
- The watchdog is enabled with an 8 s timeout after a 3 s boot delay. Do not add long blocking work without feeding or re-planning the watchdog.
- IRAM usage is already **95 %** (62,551 / 65,536 bytes) in the verified build. Check the size report before adding IRAM-heavy code.
- Code-level defects found during this documentation round are recorded, not fixed: `clever` is not persisted, a config parse/mount failure does not apply defaults, and several string literals produce `-Wwrite-strings` warnings. See `docs/modules/firmware/configuration.md` and `docs/modules/firmware/README.md`.

## Build and artifact constraints

- `libraries/libraries.zip` is the pinned library snapshot. Extract it to a libraries folder; do not upgrade, patch, or “clean up” libraries in place without a recorded build and hardware check.
- Build from the repository root with the extracted libraries on `--libraries`. Keep build directories and toolchains under `temp/`; do not commit them.
- `releases/` and `factory_firmware/` are inherited upstream artifacts. Do not overwrite them. A new release needs a new dated directory and maintainer approval.
- `factory_firmware/image4M.bin` is **4,000,000 bytes** (`0x3D0900`), not a full 4 MiB (`0x400000`) dump, and it came from the upstream author's device. Never treat it as a per-unit backup for this fork's clock.
- No automated tests exist. A compile is not a hardware test; state separately what was compiled, flashed, observed on a device, and deployed.

## Documentation rules

- Documentation language is **English**, matching the existing public README.
- `docs/DEVELOPMENT.md` is the only current-state and next-task entry. `README.md` is navigation plus a short project introduction. Do not add repository TODO, ROADMAP, STATUS, “latest”, or handoff files.
- Binary reference media stay at their existing paths: `docs/datasheets/`, `docs/display/`, `docs/images/`, `KiCad/`, `releases/`, `factory_firmware/`. They are assets, not narrative documents.
- Project-specific operations belong in `docs/history/fork-operations.md`; raw or copied evidence belongs in `docs/evidence/`; migration and maintenance records belong in `docs/maintenance/`.
- The project has no issue tracker IDs. Use date-stamped task names such as `DOC-2026-11-08` or `DEP-2026-11` in the entry.
- Documentation maintenance binding: follow the applicable global `AGENTS.md` §6 and the `doc-governance` skill. Default capacity warnings apply: entry 8,000; design/validation navigation 4,000; a module/topic navigation 6,000 LF source characters. Do not raise them to hide growth.
- Any persistent change updates `docs/DEVELOPMENT.md` in the same round and replaces stale conclusions. Do not close UNKNOWN/FAILED/NOT_RUN items or a paused decision by reorganising text.

## Git and delivery

- Default branch `master`; `origin` is the fork `https://github.com/harrywenjie/ChineseWallClock.git`. Never push to the upstream `halacs/wallclock` without an explicit request.
- Commit prefixes: `docs:`, `feat:`, `fix:`, `test:`, `chore:`.
- Do not commit `temp/`, build outputs, toolchains, credentials, or private network identifiers. The repository already contains upstream deployment screenshots; do not transcribe their SSIDs, LAN addresses, MAC addresses, or other private network details into new text.
- The fork is behind upstream (upstream has commits after 2025-07-25). Syncing or merging upstream is a separate, explicitly authorised task; do not do it as part of documentation work.
