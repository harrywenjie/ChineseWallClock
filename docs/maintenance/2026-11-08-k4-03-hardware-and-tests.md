# 2026-11-08 K4-03 Hardware and Test Record Update

## 1. Scope and boundary

- **Date:** 2026-11-08.
- **Trigger:** the maintainer supplied a second Codex summary covering soldering, serial/GND troubleshooting, backup and the post-flash observations, then confirmed the deployment date, network-loss recovery and the auto-brightness result.
- **Scope:** add the hardware-preparation and backup records, update the deployment/validation/entry/history/module docs, and reconcile the private backup policy.
- **Non-goals:** no code, dependency, build, flash, restore or hardware change. The raw backup is not copied into the repository.

## 2. Source and findings

- Deployment date is **2026-07-23** (maintainer-confirmed).
- The actual unit is a **K4-03**; upstream reference is K2-02. One unit passing the tested functions does not prove all K4-03 revisions.
- Header confirmations: pin 1 FLASH/GPIO0 and pin 3 GND confirmed; pin 2 not used/likely RST; pins 4/5 serial pair confirmed but the text record does not finally assign TX vs RX; pin 6 +5V confirmed but not used for the stable setup.
- Power/wiring: clock on its own USB-A; CP2102 on its own USB; common GND; CP2102 +5V/3V3 unconnected; no RST/DTR/RTS; manual GPIO0 boot mode and `--before/after no-reset`.
- Soldering/GND troubleshooting: the clock once looked bricked, then recovered after cleaning and returning to minimal wiring; no specific short was proven. The GND A/B/C tests passed, so common ground was correct.
- Backup: 4,194,304 bytes, SHA-256 `59FC45E91B37DCAD5C4E60E90416E3351D303A7CB8739B791CBD999FDC0CA37E`; two historical reads matched. A content check found the saved SSID at `0x3FD010` and duplicate `0x3FE010`, so the image is not firmware-only. The password encoding was not decoded.
- Post-flash: Wi-Fi configuration reused, configuration AP closed, network-loss recovery reported, auto brightness too dark and replaced by fixed manual brightness.

## 3. Mapping and disposition

| Location | Change |
|---|---|
| `docs/evidence/2026-07-23-k4-03-hardware-preparation.md` | New: soldering, serial/GND troubleshooting, pin confirmations, download mode, backup, auto-brightness finding, checklist |
| `docs/evidence/2026-07-23-k4-03-backup-manifest.md` | New: private backup, size/hash, content check, restore plan, no repo copy |
| `docs/evidence/2026-07-23-k4-03-deployment.md` | Confirmed date; added AP closure, network-loss recovery, auto-brightness workaround, hardware links |
| `docs/VALIDATION.md` | Added network-loss recovery PASS (human report); auto brightness FAILED/USABILITY; display detail partial |
| `docs/DEVELOPMENT.md` | Confirmed date and human results; auto-brightness workaround in current state/open item |
| `docs/history/fork-operations.md`, `docs/history/README.md` | Added hardware preparation/backup records and human feedback |
| `docs/modules/hardware/README.md` | Added preparation/backup links; clarified pin 4/5 direction; backup privacy |
| `docs/modules/deployment/README.md` | Added human results and hardware-prep/backup links |
| `docs/modules/factory-firmware/README.md` | Current verified backup filename; private handling; no repo copy |
| `docs/modules/firmware/configuration.md`, `display.md`, `time.md` | Observed auto-brightness change, display note, network-loss recovery caveat |
| `README.md`, `AGENTS.md` | Navigation, K4-03 state, private-backup policy, no raw image in repo |
| `.gitignore` | Reverted to the original `BACKUPS`/`temp`; the temporary `archive/` entry was removed |

## 4. Backup handling

- The maintainer initially asked for the raw backup to be copied into the repository. A local ignored copy was made and verified, then the maintainer cancelled the archive request and said they would back it up manually.
- The local `archive/K4-03_FACTORY_VERIFIED.bin` copy was deleted; `archive/` was removed and `.gitignore` reverted.
- No raw binary is tracked, staged or pushed. Only the manifest, size/hash and restore plan are committed.
- The full image contains the saved Wi-Fi configuration (SSID confirmed at `0x3FD010`); it must remain private. The raw chat logs are not committed either.
- The upstream K2-02 `factory_firmware/image4M.bin` was not modified and is not a K4-03 restore image.

## 5. Validation

- **Links/anchors:** Python checker over tracked Markdown; **191 local links checked, 0 broken**.
- **Capacity (LF source characters):** entry **7,995** (limit 8,000); design **3,960** (4,000); validation **3,996** (4,000); firmware overview **6,000** (6,000); display **5,952** (6,000); hardware **5,990** (6,000); factory firmware **5,993** (6,000); time **4,557**; logging **2,951**; configuration **9,558**, build-and-flash **8,754**, deployment **11,055**, fork operations **10,009**. The last four are detailed contract/runbook/history pages, not navigation indexes; they are linked from the module maps and not default full reads.
- **Static checks:** `git diff --check` run before delivery; no code or dependency changes.
- **Evidence boundary:** the deployment software path and human-reported recovery are documented; detailed display segments, A0/PWM measurements and RTC-only fallback remain unverified. The agent did not access the clock or the private backup.
- **Product qualification:** one K4-03 unit, not proof of K2-02/K4-03 equivalence.

## 6. Follow-up

- Capture detailed display segment/ghosting/second-LED results.
- Measure `A0` and PWM in bright/dark conditions before changing auto brightness; fixed brightness is the current workaround.
- Isolate RTC-only fallback from Wi-Fi reconnection if time retention needs a formal qualification.
- Test OTA, web-UI upload, watchdog under network loss, power-cycle persistence and long-term Wi-Fi stability.
- Keep the private K4-03 backup outside the repository; verify size/hash before any restore.
- **Next task:** `VAL-2026-11` — hardware checklist and A0 measurements; a record, not execution authorisation.
- **Delivery:** pushed with this documentation update on 2026-11-08; use `git log` for the exact commit.
