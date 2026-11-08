# Validation and Evidence

This page records what is proven, by what evidence, and what remains unverified. It does not create product qualification.

## 1. Qualification rule

Compile proves only that the source builds; an artifact hash only that the file exists; hardware runtime and deployment also require a device, backup, image/offset, config and post-flash checks. Do not merge these classes into a single “works”.

## 2. Status

| Claim | Status | Evidence / reason |
|---|---|---|
| Documentation links/anchors resolve | **PASS** — 2026-11-08 | Link checker; maintenance record |
| Firmware compiles at `d55188e` | **PASS** — 2026-11-08 | [local build](evidence/2026-11-08-local-build.md) |
| 2026-07-23 fork build succeeded | **PASS** — 2026-07-23 | [fork build evidence](evidence/2026-07-23-fork-build/README.md) |
| Byte-identical v1.1 rebuild | **UNKNOWN** | 485,280 vs 485,248 bytes; cause not isolated |
| Fork deployment on a real clock | **待核实** | Reported; no date/unit/image/offset/log found |
| Hardware runtime | **NOT_RUN** | No device on the bench |
| Web-UI firmware upload | **FAILED / OPEN** (upstream report) | Not reproduced here |

## 3. Builds

**2026-11-08 (current):** source `d55188e`; Arduino CLI 0.35.3, ESP8266 core 3.1.2, bundled libraries; exit 0; image **485,280 bytes**, SHA-256 `4898BF9BCBC4A510E986CD5E6F3207AB56E3DFB6A18EE0DC090811BE784950C6`; RAM 46 %, IRAM 95 %, flash 42 %; 14 `-Wwrite-strings` warnings, no errors. No device connected. Full record: [2026-11-08 build](evidence/2026-11-08-local-build.md).

**2026-07-23 (fork session):** installed the core, extracted the pinned libraries, rendered the schematic and produced five variants. All completed without errors; all full images are 485,280 bytes. Exact commands were not logged; build options and compiler logs are the evidence. No flash/serial/deployment log was found. Full record: [2026-07-23 fork build](evidence/2026-07-23-fork-build/README.md).

<a id="release-rebuild"></a>

## 4. Release rebuild

| Image | Bytes | SHA-256 |
|---|---|---|
| v1.0 (2024-03-23) | 483,760 | `72D7383EA63664A127B3690B6DBD2D093DC2947A1FE6CFD037FE30BD43D3126E` |
| v1.1 (2024-04-01) | 485,248 | `1FB0CBA700ABF0A0E40269F0E3E318C88EC17D31ED82C11954014293D62129FC` |
| 2026-11-08 build | 485,280 | `4898BF9BCBC4A510E986CD5E6F3207AB56E3DFB6A18EE0DC090811BE784950C6` |

The source is code-identical to v1.1 (`git diff 7d18e68..HEAD` touches no code), yet the image is 32 bytes larger. Exact rebuild is **UNKNOWN**; possible causes include core/library patch versions, build flags or build-path effects. Build-path changes can alter the hash while keeping the size, so hashes compare only with the same path/toolchain.

<a id="hardware-and-deployment"></a>

## 5. Hardware and deployment

Not run: display segments/latch timing/flicker, brightness and light sensor, DS3231 fallback/drift, WiFi/AP/NTP/DST, OTA, watchdog under network loss, power-cycle persistence, corrupt-config recovery and the actual fork deployment.

Releases are hashed in §4. The upstream screenshots show a working deployment of the upstream firmware, but they are not evidence of the fork's unit, image or configuration; the factory dump is from the upstream author's device and is not a per-unit backup.

## 6. Extending and preserving evidence

1. Follow the [deployment runbook](modules/deployment/README.md) and capture its [record template](modules/deployment/README.md#record-template).
2. Keep the full factory backup and hash before flashing; record image hash, flash tool/version/offset and serial boot log.
3. Check display, time, DST, brightness, web UI, OTA and power-cycle recovery on the device.
4. Add a dated evidence page and update `docs/DEVELOPMENT.md` §1/§5; do not edit old evidence to look successful.
5. Preserve raw logs as copied. Redact or omit private network identifiers (SSID, LAN addresses, MAC). `UNKNOWN`, `FAILED` and `NOT_RUN` stay so until new evidence or an explicit maintainer decision changes them.
