# ChineseWallClock — Development Entry

This is the only current-state and next-task entry. Read §1, §2, §5 and §7 first, check §3 for scope, then follow only the reading conditions needed. Other pages are not default full reads.

## 1. Current snapshot

**Goal:** keep the firmware buildable and maintain an evidence-backed record of the fork's K4-03 build/deployment. No active feature work.

**Non-goals:** firmware changes, dependency upgrades, opening/flashing the clock, merging upstream, publishing a release.

**Focus:** `DOC-2026-11-08` — documentation baseline plus the K4-03 deployment record.

**Latest validation:** 2026-07-23 K4-03 deployment **PASS** (build/flash/verify/boot/config/Wi-Fi/AP; recovery reported) — [record](evidence/2026-07-23-k4-03-deployment.md); 2026-11-08 compile **PASS** (485,280 bytes, IRAM 95 %) — [build](evidence/2026-11-08-local-build.md). Auto brightness too dark; fixed workaround. Detailed display/RTC still partial.

**Deployment baseline:** actual K4-03, 2026-07-23; firmware `5E4F…` (485,280 B), esptool 5.3.1, `0x000000`, verified; inherited v1.1 (485,248 B) is upstream.

**Blockers:** detailed display/RTC results and the auto-brightness cause are not recorded.

## 2. Authoritative sources and reading conditions

| Need | Read | Condition |
|---|---|---|
| Upstream intent, inherited releases/factory artifacts | [`README.md`](../README.md), [`history/README.md`](history/README.md) | Provenance or original intent |
| Fork-local operations and build evidence | [`history/fork-operations.md`](history/fork-operations.md), [`2026-07-23 build`](evidence/2026-07-23-fork-build/README.md) | Reconstructing what was built |
| Actual K4-03 deployment | [`2026-07-23 deployment`](evidence/2026-07-23-k4-03-deployment.md) | Reproducing flash/boot/config |
| Firmware behaviour | [`modules/firmware/README.md`](modules/firmware/README.md) | Before changing firmware |
| Hardware, pinout, schematic, datasheets | [`modules/hardware/README.md`](modules/hardware/README.md) | Before wiring, flashing or restoring |
| Build, images, offsets, OTA | [`modules/build-and-flash/README.md`](modules/build-and-flash/README.md) | Before compiling/flashing |
| End-to-end deployment | [`modules/deployment/README.md`](modules/deployment/README.md) | Before opening/flashing a clock |
| Validation qualifications | [`VALIDATION.md`](VALIDATION.md) | When claiming something works |
| Factory backup and original UI | [`modules/factory-firmware/README.md`](modules/factory-firmware/README.md) | Before restoring/replacing factory firmware |
| Documentation binding | §4, [`AGENTS.md`](../AGENTS.md) | Every doc change |
| Global agent rules | Applicable global `AGENTS.md` (DSH §6) | Every round; do not copy it here |

## 3. Current work package and pass conditions

- **Task:** `DOC-2026-11-08`.
- **Scope:** create this entry, thin project `AGENTS.md`, design/validation navigation, module docs, fork-operations history, preserved build evidence, migration record and the actual K4-03 deployment record; replace README with navigation.
- **Pass conditions:** one current-state entry; old README content mapped without semantic loss; local links/anchors valid; temp records preserved; entry/design/validation navigation under capacity warnings; `git diff --check` clean; no code/dependency changes.
- **Boundary:** the maintainer authorised documentation work and preservation of fork-local records only. No code, hardware, flashing or deployment authorisation.

## 4. Each-round development and closeout

- Follow the applicable global `AGENTS.md` flow. This section records only project commands/environment.
- **Doc binding:** layering, capacity, review, exit and unresolved-item rules are in global `AGENTS.md` §6 and the `doc-governance` skill. Do not copy them here.
- **Project doc rules:** English; binary media stays in `docs/datasheets/`, `docs/display/`, `docs/images/`, `KiCad/`, `releases/`, `factory_firmware/`; fork operations go to `docs/history/fork-operations.md`; raw evidence to `docs/evidence/`; maintenance records to `docs/maintenance/`.
- **Provenance:** tracked history is upstream history. Never present an upstream commit, screenshot, release or factory dump as fork work. Fork-local build work exists only in `temp/` and the preserved evidence; the deployment is recorded in `docs/evidence/2026-07-23-k4-03-deployment.md`.
- **Validation boundary:** compile/docs checks are local; hardware, NTP/WiFi, display, OTA, web UI and deployment are separate evidence classes.

## 5. Decisions and open items

| Item | Status, impact and next step | Detail |
|---|---|---|
| K4-03 hardware compatibility | **PARTIAL** — software/network pass; display details and auto-brightness cause not recorded; fixed-brightness workaround. Next: verify. | [deployment record](evidence/2026-07-23-k4-03-deployment.md) |
| Web-UI firmware upload | **OPEN** — upstream reports broken; not reproduced here. Reproduce, then fix or document serial/OTA. | [firmware notes](modules/firmware/README.md#known-implementation-notes) |
| Persistence defects | **OPEN** — `clever` not saved; parse/mount failure leaves zeroed config. Verify on hardware. | [configuration](modules/firmware/configuration.md#known-persistence-defects) |
| Exact v1.1 rebuild | **UNKNOWN** — current source is reproducible with a fixed epoch, but 485,280 B vs v1.1 485,248 B; no byte-identical claim. | [validation](VALIDATION.md#release-rebuild) |
| Upstream divergence | **OPEN** — fork HEAD `d55188e` (2025-07-25); upstream has newer commits (pushed 2026-09-05); no merge/sync decision. | [provenance](history/README.md#provenance) |
| Timezone dropdown, UI password, MQTT | **OPEN** — inherited upstream feature gaps; no commitment or schedule. | [firmware](modules/firmware/README.md#open-product-items) |

Unresolved items are not closed by documentation work. `UNKNOWN`, `FAILED`, `NOT_RUN` and paused decisions keep their state until new evidence or an explicit maintainer decision.

## 6. Commands and validation boundaries

| Command | Purpose | Boundary |
|---|---|---|
| `arduino-cli --config-file temp/arduino-cli.yaml compile --fqbn esp8266:esp8266:d1_mini --libraries temp/bundled/libraries --build-path temp/build/verify --output-dir temp/artifacts/verify .` | Compile with the pinned toolchain/libraries | Local compile only |
| `git diff --check` | Whitespace/conflict check | Repository hygiene |
| Python link/anchor checker in `temp/docs-migration/` | Check local Markdown links/headings | Result recorded in maintenance |

- **Environment:** Windows 11, Arduino CLI 0.35.3, ESP8266 core 3.1.2, bundled libraries; original author used Ubuntu 22.04.4, Arduino IDE 2.3.2, Wemos D1 mini test board.
- **Not covered:** detailed K4-03 display/RTC/brightness checks, OTA upload, web-UI upload, power loss, long-term drift and watchdog behaviour under network loss. Build/flash/verify/boot/config/Wi-Fi are covered by the [deployment record](evidence/2026-07-23-k4-03-deployment.md).

## 7. Current handoff and next task card

<a id="current-next"></a>

**Safe point:** `DOC-2026-11-08` complete; K4-03 deployment recorded; build/flash/boot/config/Wi-Fi passed; hardware checks partial.

**Minimal input:** `AGENTS.md`, this entry §1/2/5/7, the [deployment record](evidence/2026-07-23-k4-03-deployment.md) and the relevant module doc.

**Next candidate:** `VAL-2026-11` — run the hardware checklist (segments, RTC retention, auto brightness, OTA); record results; no reflash unless needed.

**Pass conditions:** observations/logs/failures recorded; update entry §1/5 and `docs/VALIDATION.md`. Reflash only with explicit approval and a fresh backup hash check.

**Not expanded:** upstream merge, feature work, dependency upgrades, release publication, or opening/flashing the clock without explicit authorisation.

**Authorisation boundary:** the next task card is a record, not execution authorisation. The maintainer's latest pause/refusal/project boundary takes precedence.
