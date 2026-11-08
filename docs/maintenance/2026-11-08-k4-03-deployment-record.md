# 2026-11-08 K4-03 Deployment Record Addition

## 1. Scope and boundary

- **Date:** 2026-11-08.
- **Baseline:** repository at `6eed13a` (previous documentation migration), fork `master`.
- **Trigger:** the maintainer supplied the Codex chat log from the actual K4-03 flash and asked for the real steps to be preserved for future reproduction.
- **Scope:** add the curated deployment record and update the entry, validation, history, deployment, hardware, build, factory-firmware, firmware configuration/time/display pages, README and AGENTS.
- **Non-goals:** no code, dependency, build, flash, hardware or upstream-merge change. No claim of full hardware compatibility beyond what the supplied log shows.

## 2. Source and provenance

- The source is a user-provided Codex session log; the deployment date is **2026-07-23**, inferred from the build artifacts. The chat excerpt shows a shell timestamp of 14:52 but no date.
- The log covers the pre-flash audit, build, approval, esptool write, automatic + independent verification, first boot, web UI, configuration change and Wi-Fi preservation.
- The raw chat log is not committed. The public record is [2026-07-23 K4-03 deployment](../evidence/2026-07-23-k4-03-deployment.md).
- Private values omitted from the public record: MAC address, SSID, LAN addresses, AP chip suffix and the private backup path. The K4-03 factory backup contains the saved Wi-Fi configuration (SSID confirmed in the SDK region) and must never enter Git.
- Retained values: the actual unit is a **K4-03**; ESP8266EX, 26 MHz, 4 MB; CP210x on `COM3`; backup 4,194,304 bytes, SHA-256 `59FC45E91B37DCAD5C4E60E90416E3351D303A7CB8739B791CBD999FDC0CA37E`; flashed image 485,280 bytes, SHA-256 `5E4F281421DCE894FED3F03DD9599AF8A690218A85C70B6A5A5DB466748D3D1D`; esptool 5.3.1; offset `0x000000`; no full erase; verification passed.

## 3. Mapping and disposition

| Location | Change |
|---|---|
| `docs/evidence/2026-07-23-k4-03-deployment.md` | New curated record: hardware, backup, build, flash, verification, redacted boot logs, config, Wi-Fi preservation, remaining tests |
| `docs/DEVELOPMENT.md` | Actual deployment replaces “待核实”; current validation/baseline/next task updated |
| `docs/VALIDATION.md` | Deployment software path PASS; hardware compatibility PARTIAL; reproducible build status |
| `docs/history/fork-operations.md` | Timeline, actual unit, deterministic build, deployment summary, remaining gaps |
| `docs/modules/deployment/README.md` | Recorded K4-03 deployment table and unit-specific flash notes |
| `docs/modules/hardware/README.md` | K2-02 vs K4-03 distinction, actual UART/header wiring, GPIO15 risk |
| `docs/modules/build-and-flash/README.md` | Actual build parameters, `SOURCE_DATE_EPOCH`, final hash, K4-03 flash setup |
| `docs/modules/factory-firmware/README.md` | Actual K4-03 per-unit backup and restore caveats; upstream K2-02 dump not a substitute |
| `docs/modules/firmware/configuration.md` | Observed first-boot defaults and saved `Pacific/Auckland` configuration |
| `docs/modules/firmware/time.md` | `Pacific/Auckland`/`nz.pool.ntp.org` deployment note and TZDB caveat |
| `docs/modules/firmware/display.md` | K4-03 initial visual check and GPIO15/OE reset risk |
| `docs/modules/firmware/README.md` | Actual K4-03 deployment pointer |
| `README.md`, `AGENTS.md` | K4-03 actual unit, deployment link, private-backup/redaction constraints |
| `docs/maintenance/2026-11-08-docs-migration.md` | Forward pointer to this record; historical status preserved |

## 4. Preservation and privacy

- The original chat log is not committed; it contains private network identifiers and a full-flash backup hash/path.
- The curated record retains the operational steps, hashes, commands and boot-log behaviour while replacing private values with placeholders.
- The K4-03 backup was not copied, moved or modified. Its size/hash are recorded, but the file stays outside the repository.
- The upstream K2-02 `factory_firmware/image4M.bin` remains untouched and is explicitly marked as not a K4-03 recovery image.
- No historical record was rewritten to make the deployment appear earlier; the new record is date-stamped and linked.

## 5. Validation

- **Links/anchors:** Python checker over tracked Markdown; **165 local links checked, 0 broken**.
- **Capacity (LF source characters):** entry **7,968** (limit 8,000); design **3,960** (4,000); validation **3,995** (4,000); firmware overview **6,000** (6,000); display **5,942** (6,000); hardware **5,986** (6,000); factory firmware **5,989** (6,000); time **4,345**; configuration **9,428**, build-and-flash **8,754**, deployment **10,549**, fork operations **8,976**. The last four are detailed contract/runbook/history pages, not navigation indexes; they are linked from the module maps and not default full reads. Their sizes are recorded for the next review rather than hidden by renaming or splitting.
- **Static checks:** `git diff --check` run before delivery; no code or dependency changes.
- **Evidence boundary:** the deployment software path is PASS based on the supplied chat log; detailed display/RTC/brightness tests remain partial. This round did not access the clock or the private backup.
- **Product qualification:** no new hardware qualification was created by the documentation. The deployment is one observed unit, not proof of K2-02/K4-03 equivalence.

## 6. Follow-up

- Run the remaining hardware checks: display segments/ghosting, second LEDs, RTC offline retention, automatic-brightness polarity, OTA, watchdog under network loss, power-cycle persistence.
- Record the exact deployment date/time if it can be recovered from the original session.
- Keep the private K4-03 backup offline; verify its hash before any restore.
- Do not treat the upstream K2-02 factory image as a K4-03 restore image.
- **Next task:** `VAL-2026-11` — hardware checklist on the deployed unit; this is a record, not execution authorisation.
- **Delivery:** the deployment record was committed as `ec6507f` and pushed to `origin/master` on 2026-11-08; this delivery note was corrected in a follow-up commit.
- **Superseded details:** the confirmed date, hardware preparation, backup handling and human test results are updated in the [hardware and tests record](2026-11-08-k4-03-hardware-and-tests.md). The rest of this record remains historical.
