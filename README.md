<a href="https://www.buymeacoffee.com/halacs" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>

**ABSOLUTELY NO WARRANTY! USE AT YOUR OWN RISK!**

# Chinese Wall Clock

Open-source replacement firmware for the **Baiyangshu 1902 Wifi Clock K2 02** (“Chinese Wall Clock”). It replaces the factory firmware with an ESP8266/Arduino firmware that adds a web UI, NTP + DS3231 timekeeping with DST-aware time zones, automatic brightness, Arduino OTA and syslog.

This repository is a fork of [`halacs/wallclock`](https://github.com/halacs/wallclock), maintained at [`harrywenjie/ChineseWallClock`](https://github.com/harrywenjie/ChineseWallClock). The upstream target is the K2-02; this fork's actual unit is a **BAIYANGSHU K4-03**. The tracked source is upstream; fork-local operations and the actual deployment are documented separately.

![Device](docs/images/device_picture.png)

## Start here

- **[Development entry](docs/DEVELOPMENT.md)** — current state, open items and the next task. Read this first.
- **[Hardware](docs/modules/hardware/README.md)** — board, components, pinout, programming header, schematic and datasheets.
- **[Firmware behaviour](docs/modules/firmware/README.md)** — boot flow, configuration, display, time, logging and known implementation notes.
- **[Build and flash](docs/modules/build-and-flash/README.md)** — toolchain, pinned libraries, image forms, offsets, OTA and common failures.
- **[Deployment runbook](docs/modules/deployment/README.md)** — end-to-end procedure for a similar clock, including the factory-backup checklist and record template.
- **[Factory firmware](docs/modules/factory-firmware/README.md)** — original 4,000,000-byte dump, extraction command and the factory UI.
- **[History and provenance](docs/history/README.md)** — upstream baseline vs fork-local operations and the preserved 2026 build evidence.
- **[Validation](docs/VALIDATION.md)** — what is proven, what is not, and the evidence boundaries.
- **[Actual K4-03 deployment](docs/evidence/2026-07-23-k4-03-deployment.md)** — the real flash, verification, first boot and configuration record (private identifiers redacted).
- **[K4-03 hardware preparation](docs/evidence/2026-07-23-k4-03-hardware-preparation.md)** — soldering, serial/GND troubleshooting, pin confirmations and download mode.
- **[K4-03 backup manifest](docs/evidence/2026-07-23-k4-03-backup-manifest.md)** — private full-flash backup and restore plan (raw image not in repo).

## Releases and hardware files

- [Release binaries](releases/) — inherited v1.0 (2024-03-23) and v1.1 (2024-04-01).
- [Upstream K2-02 factory firmware dump](factory_firmware/image4M.bin) — not a K4-03 recovery image; see the caveats in the [factory firmware page](docs/modules/factory-firmware/README.md).
- [KiCad schematic](KiCad/schematic.pdf).
- [Pinned Arduino libraries](libraries/libraries.zip) — the author's backup; see [libraries/README.md](libraries/README.md).

## Project links

- [Author's blog post](https://www.halacs.hu/baiyangshu-1902-wifi-clock-k2-02)
- [Upstream repository](https://github.com/halacs/wallclock)

## Contributing

Open a pull request against the fork. Describe the change and how it was tested. A compile is not a hardware test; state separately what ran on a real clock. Read the [development entry](docs/DEVELOPMENT.md) and [project instructions](AGENTS.md) before changing firmware or documentation.
