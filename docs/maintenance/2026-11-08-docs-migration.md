# 2026-11-08 Documentation Migration Record

## 1. Scope and boundary

- **Date:** 2026-11-08.
- **Baseline:** fork `harrywenjie/ChineseWallClock` at `d55188e` (upstream HEAD, 2025-07-25); working tree clean before the migration; no fork commits or pushes.
- **Trigger:** the repository had no unified development entry, no project `AGENTS.md`, and the fork-local build/deployment records existed only in ignored `temp/`. The maintainer asked for documentation normalisation and preservation of fork-local operation records.
- **Scope:** README, `AGENTS.md`, `docs/DEVELOPMENT.md`, design/validation navigation, firmware/hardware/build/deployment/factory module pages, history and evidence, this maintenance record.
- **Non-goals:** no firmware/code change, dependency upgrade, upstream merge, flashing, deployment or release publication.

## 2. Pre-migration state

- **Old entry:** none. `README.md` was the only narrative document and carried product summary, feature checklist, hardware, development environment, UI screenshots, factory firmware and contribution notes.
- **Parallel current-state documents:** none (no TODO/ROADMAP/STATUS/HANDOFF files).
- **Documentation assets:** `docs/datasheets/` (PDFs), `docs/display/` (ODS/photo), `docs/images/` (device, UI, factory-firmware screenshots), `KiCad/schematic.pdf`, `releases/`, `factory_firmware/`, `libraries/libraries.zip`.
- **Fork-local records:** `temp/` (ignored) held the 2026-07-23 toolchain/build session, build logs, artifacts, a PDF virtualenv and rendered schematic pages.
- **Unresolved items:** none formally tracked; the README's unchecked items and the missing deployment record were the de facto open list.
- **Capacity baseline:** no entry/design/validation pages existed; README was 4,415 bytes.

## 3. Mapping and disposition

| Original location | Classification | Disposition | New location |
|---|---|---|---|
| README title, warranty, “Buy Me a Coffee”, blog link | Public navigation/introduction | Rewritten, links kept | `README.md` |
| README “Summary” (why replace factory firmware) | Product intent | Moved | `README.md` intro; [factory firmware](../modules/factory-firmware/README.md) |
| README feature checklist (`[x]`) | Current feature contract | Moved; no longer a README status list | [firmware overview](../modules/firmware/README.md) |
| README unchecked items (`[ ]`) | Open product items | Moved to the single open-items table; not closed | `docs/DEVELOPMENT.md` §5 |
| README “The Device” / “Hardware” | Design/hardware | Moved | [hardware](../modules/hardware/README.md) |
| README programming header, AP name/password, first boot | Design/hardware/deployment | Moved | [hardware](../modules/hardware/README.md), [deployment](../modules/deployment/README.md), [configuration](../modules/firmware/configuration.md) |
| README development environment | Build contract | Moved | [build and flash](../modules/build-and-flash/README.md) |
| README UI screenshots (landing/setup/WiFi) | Reference media | Paths retained; linked from firmware/hardware docs | `docs/images/` |
| README factory-firmware section and screenshots | Hardware/evidence | Moved | [factory firmware](../modules/factory-firmware/README.md) |
| README contribution note | Navigation/constraints | Rewritten | `README.md`, `AGENTS.md`, `docs/DEVELOPMENT.md` §4 |
| `docs/datasheets/`, `docs/display/`, `docs/images/`, `KiCad/` | Binary reference media | Retained at original paths; linked | Same paths |
| `libraries/README.md`, `libraries/libraries.zip` | Build constraint/backup | Retained; linked | Same paths; [build and flash](../modules/build-and-flash/README.md) |
| `releases/` | Inherited artifacts | Retained; documented with hashes | Same paths; [validation](../VALIDATION.md) |
| `factory_firmware/image4M.bin` | Inherited evidence | Retained; caveats documented | Same path; [factory firmware](../modules/factory-firmware/README.md) |
| `temp/logs/`, `temp/artifacts/`, `temp/arduino-cli.yaml`, `temp/render_schematic.py`, `temp/downloads/` checksums | Fork-local operations/evidence | Copied to evidence; originals left in `temp/` | [2026-07-23 fork build](../evidence/2026-07-23-fork-build/README.md) |
| 2026-11-08 fresh compile | Validation evidence | New | [2026-11-08 local build](../evidence/2026-11-08-local-build.md) |
| New entry | Current state | New | `docs/DEVELOPMENT.md` |
| New project constraints | Stable constraints | New, thin | `AGENTS.md` |
| New design/validation navigation | Navigation | New | `docs/ENGINEERING_DESIGN.md`, `docs/VALIDATION.md` |
| New deployment runbook | Contract/runbook | New | [deployment](../modules/deployment/README.md) |
| New history/provenance | History | New | `docs/history/README.md`, `docs/history/fork-operations.md` |

## 4. Preservation and de-duplication

- **Old README:** preserved in Git at `d55188e` and in the fork's history; it was replaced rather than kept as a second entry. No verbatim snapshot file was created because the content maps into the pages above and the old revision remains immutable in Git.
- **Upstream vs fork:** the migration records the fork provenance explicitly and does not attribute upstream commits, screenshots, releases or the factory dump to the fork. No upstream history was rewritten.
- **Artifacts:** `releases/` and `factory_firmware/` were not modified. Their sizes and SHA-256 values are recorded in [validation](../VALIDATION.md) and the [artifact manifest](../evidence/2026-07-23-fork-build/artifacts.sha256).
- **Temp records:** the raw build logs, CLI config, schematic script, checksum list and manifests were copied verbatim; absolute paths inside them refer to the original workspace. The originals remain in `temp/` and are not committed. `.gitattributes` marks the copied `.log` files as `-whitespace` so their console-formatting spaces do not trip `git diff --check`; the content is unchanged.
- **Anchors/links:** the old README had no heading anchors to preserve. New stable anchors were added for `release-rebuild`, `hardware-and-deployment`, `known-implementation-notes`, `known-persistence-defects`, `provenance`, `3-phase-1-full-factory-backup` and `record-template`; inbound/outbound local links were checked.
- **Generic rules:** documentation/session/Git rules are references to the applicable global `AGENTS.md` and skills; no global rule text was copied into the project.
- **Unresolved items:** the README's unchecked feature items, the missing deployment record, the exact-rebuild unknown, and the hardware-not-run status remain open or unknown; none was closed by the migration.

## 5. Validation

- **Links/anchors:** Python checker over all tracked Markdown (excluding `temp/` and copied raw-log directory); **141 local links checked, 0 broken**.
- **Capacity (LF source characters):**
  - Entry `docs/DEVELOPMENT.md`: **7,931** (limit 8,000).
  - Design `docs/ENGINEERING_DESIGN.md`: **3,935** (limit 4,000).
  - Validation `docs/VALIDATION.md`: **3,996** (limit 4,000).
  - Module navigation: firmware **5,744**, hardware **5,490**, factory firmware **5,072** (limit 6,000 each); history index **3,128**.
  - Detailed contracts over the navigation limit: `configuration.md` **8,453**, `build-and-flash/README.md` **7,269**, `deployment/README.md` **8,222**, `fork-operations.md` **6,679**. These are procedure/contract or history pages, not navigation indexes; they are linked from the entry/module maps and are not default full reads. Their size is recorded here for the next review rather than hidden by renaming or splitting.
- **Reading walkthrough:** from entry §7, the [deployment record template](../modules/deployment/README.md#record-template) is one link away; from entry §5, a non-current hardware/validation item reaches its evidence in one link. Module pages link their direct contracts and back to the entry.
- **Static checks:** link checker as above; `git diff --check` run before delivery; no code/dependency changes.
- **Build evidence:** 2026-11-08 compile pass under the documented toolchain; see [2026-11-08 local build](../evidence/2026-11-08-local-build.md). No hardware or deployment qualification was added.

## 6. Follow-up

- **Open/unknown items:** fork deployment record **待核实**; exact v1.1 rebuild **UNKNOWN**; hardware runtime **NOT_RUN**; web-UI firmware upload **OPEN/FAILED**; persistence defects **OPEN**; upstream divergence **OPEN**.
- **Next task:** `DEP-2026-11` — capture the fork's real deployment record and dry-run the runbook on a spare ESP8266/D1 mini; do not flash the clock until a full per-unit backup is verified. This is a record, not execution authorisation.
- **Next review trigger:** a new deployment record, a capacity warning, a focus change, a firmware change, or a maintainer request. The entry is near its 8,000-character warning, so a new open item should replace or merge an existing row rather than append.
- **Delivery:** documentation migration committed as `92772d1` and pushed to `origin/master` on 2026-11-08.
- **Superseded deployment status:** the `待核实` deployment item in this migration was resolved on 2026-11-08; see the [K4-03 deployment record](2026-11-08-k4-03-deployment-record.md) and the [curated evidence](../evidence/2026-07-23-k4-03-deployment.md). The rest of this migration record is historical and is not rewritten.
- **Notes:** documentation language is English; binary media stays at existing paths; the fork remains behind upstream; no code, libraries, releases or hardware were changed.
