# 2026-07-23 Fork Build Evidence

This directory preserves the fork-local build session that was kept in `temp/` and would otherwise be lost when the temporary workspace is cleaned. The copies are verbatim from `temp/`; absolute paths inside them refer to the original workspace (`E:\ChineseWallClock`) and are not portable.

## 1. What was done

On 2026-07-23 the fork was cloned at upstream `d55188e`, an Arduino toolchain was installed into `temp/`, the pinned libraries were extracted, the schematic was rendered, and five build variants were produced. The purpose appears to have been to reproduce the upstream release build; no variant matched the v1.1 release byte-for-byte.

- Date: 2026-07-23, workspace local time (UTC+12).
- Source: `d55188e` (2025-07-25), no fork code changes.
- Build completed: exit 0; no compiler errors.
- Full images: 485,280 bytes for every variant.
- Release v1.1: 485,248 bytes (32 bytes smaller); exact cause **UNKNOWN**.

## 2. Environment

| Item | Value |
|---|---|
| OS | Windows 11 |
| Arduino CLI used | 0.35.3 (`95cfd654`, 2024-02-19) |
| Arduino CLI also downloaded | 1.5.1 (not used for the preserved builds) |
| ESP8266 core | 3.1.2 |
| FQBN | `esp8266:esp8266:d1_mini` |
| Board manager URL | `https://arduino.esp8266.com/stable/package_esp8266com_index.json` |
| Compiler | `xtensa-lx106-elf-gcc` 3.1.0-gcc10.3-e5f9fec |
| Libraries | `libraries/libraries.zip` extracted to `temp/bundled/libraries` |
| PDF tooling | PyMuPDF 1.26.3, pypdf 6.1.1 |
| Build output | RAM 37,404 / 80,192 (46 %), IRAM 62,551 / 65,536 (95 %), flash 443,980 / 1,048,576 (42 %) |

See [`environment.txt`](environment.txt) for the full record.

## 3. Commands

The exact `arduino-cli` invocations were **not logged**. The compiler logs and `build.options.json` files preserve the FQBN, library folders and custom build properties; the compiler command lines are in the logs. The setup can be reconstructed as:

```text
arduino-cli core install esp8266:esp8266@3.1.2
arduino-cli compile --fqbn esp8266:esp8266:d1_mini \
  --libraries <repo>/temp/bundled/libraries \
  --build-path <repo>/temp/build/<variant> \
  --output-dir <repo>/temp/artifacts/<variant> \
  <repo>
```

For the canonical/IDE-like variants, the build options record `build.warn_data_percentage=75`. Do not treat the reconstructed command as an exact replay; use the recorded library versions and the current [build instructions](../../modules/build-and-flash/README.md).

## 4. Variants

| Variant | Build dir | Custom property | Full image | App-only image |
|---|---|---|---|---|
| default | `temp/build/default` | none | 485,280 B / `e059dada…` | 481,184 B / `8afa2544…` |
| repro2 | `temp/build/repro2` | none | 485,280 B / `52038606…` | 481,184 B / `06d42a0e…` |
| ide232-cli | `temp/build/ide232-cli` | `build.warn_data_percentage=75` | 485,280 B / `c935403d…` | — |
| canonical1 | `temp/build/canonical1` | `build.warn_data_percentage=75` | 485,280 B / `5e4f2814…` | — |
| canonical2 | `temp/build/canonical2` | `build.warn_data_percentage=75` | 485,280 B / `5e4f2814…` | — |

Full hashes and sizes are in [`build-options.tsv`](build-options.tsv) and [`artifacts.sha256`](artifacts.sha256). The app-only image is the full image minus its first 4,096 bytes; it is not a separate firmware.

## 5. Preserved files

| File | What it is |
|---|---|
| [`build-default.log`](build-default.log) | Full compiler log for the `default` build (707,561 bytes) |
| [`build-canonical-ide232-cli.log`](build-canonical-ide232-cli.log) | Compiler log for the IDE-like canonical build (72,791 bytes) |
| [`arduino-cli.yaml`](arduino-cli.yaml) | Local CLI config with absolute `temp/` paths |
| [`render_schematic.py`](render_schematic.py) | PyMuPDF/pypdf script that rendered the schematic |
| [`arduino-cli_0.35.3-checksums.txt`](arduino-cli_0.35.3-checksums.txt) | Official checksum list for the downloaded CLI archive |
| [`artifacts.sha256`](artifacts.sha256) | Hashes/sizes for fork build artifacts, inherited releases and the factory dump |
| [`environment.txt`](environment.txt) | Environment summary |
| [`build-options.tsv`](build-options.tsv) | Per-variant build options and image hashes |
| [`library-versions.tsv`](library-versions.tsv) | Library versions from the pinned zip, with used/unused flags |
| [`preserved-files.sha256`](preserved-files.sha256) | Integrity manifest for this directory |

## 6. What was not copied

The source `temp/` tree was large and machine-specific. The following are documented but not committed; they remain in the original workspace (or can be recreated):

| `temp/` item | Contents | Disposition |
|---|---|---|
| `arduino-data/` | ESP8266 core 3.1.2, package metadata, toolchain components | Version and URL recorded; not copied (hundreds of MB) |
| `arduino-downloads/` | Arduino CLI download cache | Not copied; packages can be re-downloaded |
| `artifacts/` | Build `.bin`/`.elf`/`.map` outputs | Sizes and SHA-256 in [`artifacts.sha256`](artifacts.sha256); binaries not copied |
| `build/` | Per-variant build trees and generated sources | Compiler logs copied; build options summarized; trees not copied |
| `bundled/` | Extracted libraries and Arduino user directory | Compared file-by-file with `libraries/libraries.zip`; not copied |
| `downloads/` | Arduino CLI/IDE archives and checksums | Checksum file copied; archives not copied |
| `ide-source-2.3.2/` | Arduino IDE 2.3.2 source tree | Version/size recorded; not copied |
| `pdf-venv/` | Python virtualenv (PyMuPDF 1.26.3, pypdf 6.1.1) | Package versions recorded; not copied |
| `pdfs/` | Rendered schematic: page 1 at 300 dpi and two 600 dpi detail crops | Script copied; rendered PNGs not copied |
| `toolchain/` | Arduino CLI 0.35.3 and 1.5.1 executables | Versions recorded; not copied |

If the original `temp/` tree is deleted, the build can be recreated from the vendored `libraries/libraries.zip`, the recorded core/board URL, the copied logs/config and the commands in this evidence set. The raw logs are the only record of the exact compiler command lines.

## 7. Limitations

- The exact commands and the reason for each variant name were not logged; the reconstruction is inferred from build options and logs.
- The logs contain absolute paths and a Windows user temp path; they are preserved as evidence, not as a portable script.
- No flash, boot, serial or deployment record is present. A build proves compilation only.
- No variant matched the v1.1 release. The difference is recorded as **UNKNOWN** in [validation](../../VALIDATION.md#release-rebuild); do not claim byte-identical reproduction.
- The inherited releases and factory dump are included in the hash manifest for comparison; they are upstream artifacts, not fork outputs.

## 8. Integrity check

From the repository root:

```text
Get-Content docs/evidence/2026-07-23-fork-build/preserved-files.sha256
```

The manifest lists file names, sizes and SHA-256 values. The copied logs/configs are immutable evidence; if a file is intentionally replaced, record why and update the manifest rather than silently editing it.
