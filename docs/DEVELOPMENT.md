# ChineseWallClock — Development Entry

This is the only current-state and next-task entry. Read §1, §2, §5 and §7 first, check §3 for scope, then follow only the reading conditions needed. Other pages are not default full reads.

## 1. Current snapshot

**Goal:** keep the firmware buildable and preserve an evidence-backed record of the fork's build/deployment knowledge. No active feature work.

**Non-goals:** firmware changes, dependency upgrades, flashing or opening the clock, merging upstream, publishing a release.

**Focus:** `DOC-2026-11-08` complete; documentation baseline and fork evidence in place.

**Latest validation:** 2026-11-08 local compile **PASS** — Arduino CLI 0.35.3, ESP8266 core 3.1.2, bundled libraries; 485,280-byte image; RAM 46 %, IRAM 95 %, flash 42 %. No hardware test. See [2026-11-08 build](evidence/2026-11-08-local-build.md).

**Deployment baseline:** inherited release **v1.1** (2024-04-01, 485,248 bytes; hash in validation) predates the fork. The fork's deployed image/date is **待核实**; no fork build is designated as deployed.

**Blockers:** no clock/ESP8266 on the bench; missing fork deployment record.

## 2. Authoritative sources and reading conditions

| Need | Read | Condition |
|---|---|---|
| Upstream intent, inherited releases/factory artifacts | [`README.md`](../README.md), [`history/README.md`](history/README.md) | Provenance or original intent |
| Fork-local operations and build evidence | [`history/fork-operations.md`](history/fork-operations.md), [`2026-07-23 build`](evidence/2026-07-23-fork-build/README.md) | Reconstructing what was built/deployed |
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
- **Scope:** create this entry, thin project `AGENTS.md`, design/validation navigation, module docs, fork-operations history, preserved build evidence and migration record; replace README with navigation.
- **Pass conditions:** one current-state entry; old README content mapped without semantic loss; local links/anchors valid; temp records preserved; entry/design/validation navigation under capacity warnings; `git diff --check` clean; no code/dependency changes.
- **Boundary:** the maintainer authorised documentation work and preservation of fork-local records only. No code, hardware, flashing or deployment authorisation.

## 4. Each-round development and closeout

- Follow the applicable global `AGENTS.md` flow. This section records only project commands/environment.
- **Doc binding:** layering, capacity, review, exit and unresolved-item rules are in global `AGENTS.md` §6 and the `doc-governance` skill. Do not copy them here.
- **Project doc rules:** English; binary media stays in `docs/datasheets/`, `docs/display/`, `docs/images/`, `KiCad/`, `releases/`, `factory_firmware/`; fork operations go to `docs/history/fork-operations.md`; raw evidence to `docs/evidence/`; maintenance records to `docs/maintenance/`.
- **Provenance:** tracked history is upstream history. Never present an upstream commit, screenshot, release or factory dump as fork work. Fork-local work exists only in `temp/` and the preserved evidence.
- **Validation boundary:** compile/docs checks are local; hardware, NTP/WiFi, display, OTA, web UI and deployment are separate evidence classes.

## 5. Decisions and open items

| Item | Status, impact and next step | Detail |
|---|---|---|
| Fork deployment record | **待核实** — a real deployment is reported, but no fork-specific date, unit, image, offset, config or serial log exists. Capture it with the record template before calling the fork deployed. | [template](modules/deployment/README.md#record-template) |
| Web-UI firmware upload | **OPEN** — upstream README reports it broken; not reproduced here. Reproduce with serial log + browser upload, then fix or document serial/OTA. | [firmware notes](modules/firmware/README.md#known-implementation-notes) |
| Persistence defects | **OPEN** — code inspection: `clever` is not saved; parse/mount failure does not apply defaults. Verify on hardware before fixing. | [configuration](modules/firmware/configuration.md#known-persistence-defects) |
| Exact v1.1 rebuild | **UNKNOWN** — builds are 485,280 bytes vs release 485,248; the 32-byte difference is unexplained. Do not claim a byte-identical rebuild. | [validation](VALIDATION.md#release-rebuild) |
| Hardware runtime | **NOT_RUN** — no device on the bench. Upstream screenshots are reference media, not fork runtime evidence. | [validation](VALIDATION.md#hardware-and-deployment) |
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
- **Not covered:** hardware, WiFi/NTP, DS3231 fallback, display timing, brightness sensor, OTA, web-UI upload, power loss, long-term drift and the actual fork deployment.

## 7. Current handoff and next task card

<a id="current-next"></a>

**Safe point:** `DOC-2026-11-08` is complete: this entry, the module docs, preserved evidence and migration record are delivered and checked. No firmware/hardware state changed.

**Minimal input:** `AGENTS.md`, this entry §1/2/5/7, the relevant module doc and the linked evidence.

**Next candidate:** `DEP-2026-11` — capture the fork's real deployment record and dry-run the runbook on a spare ESP8266/D1 mini. Do not flash the clock until a full per-unit backup is verified.

**Pass conditions:** record unit, full backup length/hash, image/hash/commit, flash tool/offset, configuration, serial boot log and post-flash checks; then update §1/§5.

**Not expanded:** upstream merge, feature work, dependency upgrades, release publication, or opening the clock without explicit authorisation.

**Authorisation boundary:** the next task card is a record, not execution authorisation. The maintainer's latest pause/refusal/project boundary takes precedence.
