# 2026-11-08 Local Build Evidence

This record documents the compile performed during the documentation migration round. It is a local compile only; no device was connected and nothing was flashed.

## 1. Inputs

- Source: `d55188e` (upstream HEAD; no fork code changes).
- Working tree: clean before the build.
- Toolchain: Arduino CLI 0.35.3, ESP8266 core 3.1.2.
- Libraries: `temp/bundled/libraries`, extracted from `libraries/libraries.zip`.
- Board: `esp8266:esp8266:d1_mini` (Wemos D1 mini / ESP-12F target).

## 2. Command

Run from the repository root on Windows 11:

```text
& 'temp\toolchain\arduino-cli-0.35.3\arduino-cli.exe' \
  --config-file temp\arduino-cli.yaml \
  compile \
  --fqbn esp8266:esp8266:d1_mini \
  --libraries temp\bundled\libraries \
  --build-path temp\build\docs-verify \
  --output-dir temp\artifacts\docs-verify \
  .
```

The PowerShell redirection used `*> temp\logs\docs-verify.log`; the command exited 0.

## 3. Result

| Artifact | Bytes | SHA-256 |
|---|---|---|
| `ChineseWallClock.ino.bin` | 485,280 | `4898BF9BCBC4A510E986CD5E6F3207AB56E3DFB6A18EE0DC090811BE784950C6` |
| `ChineseWallClock.ino.elf` | 7,910,144 | `30F9B311CCAC40435E8A7FCED01F547BC394DF507ED3CE3ABA0B779C77E2B273` |
| `ChineseWallClock.ino.map` | 4,703,776 | `69AB26E23B6E564E4A826F697A9C724DCE9D2881F7D3BC098AE3B8A7C9779A02` |

Memory report: RAM 37,404 / 80,192 (46 %), IRAM 62,551 / 65,536 (95 %), flash 443,980 / 1,048,576 (42 %).

Warnings: 14 `-Wwrite-strings` warnings in project code; no errors. The log also contains an Arduino CLI core-cache path warning (`Couldn't deeply cache core build: ...`) caused by the workspace temp path; it did not fail the build.

## 4. Comparison

| Image | Bytes | SHA-256 |
|---|---|---|
| v1.1 release (2024-04-01) | 485,248 | `1FB0CBA700ABF0A0E40269F0E3E318C88EC17D31ED82C11954014293D62129FC` |
| This build | 485,280 | `4898BF9BCBC4A510E986CD5E6F3207AB56E3DFB6A18EE0DC090811BE784950C6` |

The current source is code-identical to v1.1, but the image is 32 bytes larger. This is **not** a byte-identical rebuild; the cause is **UNKNOWN** (toolchain/library patch level, build flags or build-path effects). See [validation](../VALIDATION.md#release-rebuild).

## 5. Evidence files

- [`2026-11-08-local-build.log`](2026-11-08-local-build.log) — full console log (6,787 bytes).
- [`2026-11-08-local-build.sha256`](2026-11-08-local-build.sha256) — artifact and log hashes.

The binary/ELF/map remain in `temp/artifacts/docs-verify/` and are not committed. Rebuild from the command above if the artifacts are needed; compare size and memory first, and compare hashes only with the same path/toolchain.

## 6. Boundary

This evidence proves that the documented toolchain compiles the current source. It does **not** prove that the resulting image boots, flashes correctly, drives the display, connects to WiFi, syncs time, passes OTA or matches the fork's deployed image. Those are separate hardware/deployment qualifications.
