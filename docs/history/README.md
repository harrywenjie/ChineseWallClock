# History and Provenance

This is the index for project history. It separates **upstream history** from **fork-local operations**; the distinction matters because the fork has not committed or pushed its own changes.

<a id="provenance"></a>

## 1. Provenance

| Item | Value |
|---|---|
| Upstream project | [`halacs/wallclock`](https://github.com/halacs/wallclock) |
| Fork | [`harrywenjie/ChineseWallClock`](https://github.com/harrywenjie/ChineseWallClock) |
| Fork created | 2026-01-27T20:03:16Z (GitHub API metadata) |
| Local clone | 2026-07-23 14:08:33 +12:00, from the fork remote |
| Tracked HEAD | `d55188e` (2025-07-25), identical to `origin/master` |
| Fork commits/pushes | Documentation commits only; no firmware-source changes |
| Upstream divergence | Upstream has newer commits (pushed 2026-09-05) that are not in this fork; no merge decision |

The tracked source is upstream work. `releases/`, `factory_firmware/`, `docs/images/`, `docs/display/`, `docs/datasheets/` and `KiCad/` are inherited artifacts. Fork-local build work was uncommitted and kept in `temp/`; the preserved part is under [`docs/evidence/2026-07-23-fork-build/`](../evidence/2026-07-23-fork-build/README.md). The actual K4-03 deployment is separately recorded in [`docs/evidence/2026-07-23-k4-03-deployment.md`](../evidence/2026-07-23-k4-03-deployment.md).

## 2. Index

| Page | Covers | Read when |
|---|---|---|
| [Fork operations](fork-operations.md) | 2026-07-23 build/deployment session and 2026-11-08 documentation round | Reconstructing what the fork actually did |
| [2026-07-23 build evidence](../evidence/2026-07-23-fork-build/README.md) | Tool versions, build variants, artifacts, logs | Auditing the fork build |
| [2026-07-23 K4-03 deployment](../evidence/2026-07-23-k4-03-deployment.md) | Actual flash, verification, first boot, config, Wi-Fi preservation | Reproducing or auditing the deployment |
| [2026-11-08 local build](../evidence/2026-11-08-local-build.md) | Current compile verification | Checking the latest build |
| [Deployment runbook](../modules/deployment/README.md) | Future deployment procedure and record template | Preparing a similar clock |
| [Factory firmware](../modules/factory-firmware/README.md) | Inherited factory dump and original UI | Before restoring or replacing factory firmware |

## 3. What not to infer

- The upstream screenshots show a working deployment of the upstream firmware. They are **not** evidence of the fork's unit, image or configuration.
- The 2024 release binaries and factory dump predate the 2026 fork. Their presence in the fork does not mean the fork built or deployed them.
- The 2026-07-23 build session proves the fork could compile the upstream source. The separate [K4-03 deployment record](../evidence/2026-07-23-k4-03-deployment.md) records the flash, verification, first boot and configuration; neither source proves full hardware compatibility.
- The actual deployment is one K4-03 unit. It does not prove K2-02/K4-03 equivalence, and it does not close the untested display/RTC/brightness items in `docs/DEVELOPMENT.md` §5.

## 4. History maintenance

- New fork-local operations go to `docs/history/fork-operations.md` and, when raw evidence exists, `docs/evidence/<date>-<task>/`.
- Do not rewrite upstream history or copy upstream commit narratives as fork work.
- Do not close a failed/not-run test or a partial hardware check by reorganising this page.
- Historical evidence records what was observed then; it does not create a current qualification. Current qualifications are in `docs/VALIDATION.md`.
