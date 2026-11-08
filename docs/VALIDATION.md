# Validation and Evidence

This page records what is proven, by what evidence, and what remains unverified. It does not create product qualification.

## 1. Qualification rule

Compile proves only that the source builds; a hash only that the file exists; deployment also requires a device, backup, image/offset, config and post-flash checks. Do not merge these classes into a single “works”.

## 2. Status

| Claim | Status | Evidence / reason |
|---|---|---|
| Firmware compiles at `d55188e` | **PASS** — 2026-11-08 | [local build](evidence/2026-11-08-local-build.md) |
| K4-03 flash + verification | **PASS** — 2026-07-23 | [deployment record](evidence/2026-07-23-k4-03-deployment.md) |
| K4-03 boot, config, Wi-Fi/AP | **PASS** — 2026-07-23 | Same record; AP closed, Wi-Fi reused |
| K4-03 network-loss recovery | **PASS** — human report | Automatic recovery; RTC/Wi-Fi path not isolated |
| K4-03 detailed display compatibility | **PARTIAL** | Initial visual normal; segment mapping not recorded |
| Auto brightness on K4-03 | **FAILED / USABILITY** | Too dark; fixed manual brightness workaround |
| Byte-identical v1.1 rebuild | **UNKNOWN** | 485,280 vs 485,248 bytes; cause not isolated |

## 3. Builds

**2026-07-23 deterministic build:** Arduino CLI 0.35.3, core 3.1.2, bundled libraries; `SOURCE_DATE_EPOCH=1711661163`; two clean builds byte-identical; image **485,280 bytes**, SHA-256 `5E4F281421DCE894FED3F03DD9599AF8A690218A85C70B6A5A5DB466748D3D1D`.

**2026-11-08 local compile:** same source/toolchain/libraries without the fixed epoch; exit 0; 485,280 bytes, SHA-256 `4898…50C6`; 14 warnings, no errors. Full record: [2026-11-08 build](evidence/2026-11-08-local-build.md).

## 4. Actual K4-03 deployment

The actual K4-03 was flashed on **2026-07-23** (maintainer-confirmed). A full 4 MiB backup was made twice with matching SHA-256 `59FC…E37E`; firmware `5E4F…D3D1D` was written at `0x000000` with esptool 5.3.1, no full erase, and automatic + independent verification passed. First boot, configuration save/reload, Wi-Fi reuse, AP closure and network-loss recovery passed. Auto brightness was too dark and was replaced by fixed manual brightness. This qualifies the software/deployment path, not full hardware compatibility. Details: [deployment record](evidence/2026-07-23-k4-03-deployment.md).

<a id="release-rebuild"></a>

## 5. Release rebuild

v1.1 is 485,248 bytes, SHA-256 `1FB0…29FC`; the 2026-07-23 canonical build is 485,280 bytes, SHA-256 `5E4F…D3D1D`. The source is code-identical to v1.1 (`git diff 7d18e68..HEAD` touches no code), but the image is 32 bytes larger. Exact v1.1 rebuild is **UNKNOWN**; current source is reproducible with the fixed epoch and same build path/toolchain.

<a id="hardware-and-deployment"></a>

## 6. Hardware and remaining tests

Not recorded: detailed segment mapping/ghosting, latch timing/flicker, DS3231-only fallback, A0/PWM measurements, OTA, watchdog under network loss, power-cycle persistence, long-term drift and K2-02 vs K4-03 electrical differences. Network-loss recovery is reported; RTC/Wi-Fi path not isolated.

K4-03 risks: GPIO15 is a low boot strap and the active-low 74HC595 OE may enable outputs briefly at reset; the display mapping is hard-coded; auto brightness is too dark on this unit (use fixed brightness until measured); the blue LED is not controlled. Web-UI firmware upload remains unverified.

## 7. Extending and preserving evidence

1. Run the [deployment runbook](modules/deployment/README.md) hardware checklist on the deployed unit; capture serial logs and observations.
2. Before any reflash, re-check the private K4-03 backup hash and the firmware hash/offset; never use the upstream K2-02 factory image for a K4-03 restore.
3. Add a dated evidence page and update `docs/DEVELOPMENT.md` §1/§5; do not edit historical observations to look successful.
4. Redact private identifiers; never commit the private backup. `UNKNOWN`, `FAILED` and `NOT_RUN` stay until new evidence or an explicit decision.
