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
| Fork commits/pushes | None as of 2026-11-08; the fork's last push timestamp is the upstream commit |
| Upstream divergence | Upstream has newer commits (pushed 2026-09-05) that are not in this fork; no merge decision |

The tracked tree is upstream work. `releases/`, `factory_firmware/`, `docs/images/`, `docs/display/`, `docs/datasheets/` and `KiCad/` are inherited artifacts. Fork-local work was uncommitted and kept in `temp/`; the preserved part is under [`docs/evidence/2026-07-23-fork-build/`](../evidence/2026-07-23-fork-build/README.md).

## 2. Index

| Page | Covers | Read when |
|---|---|---|
| [Fork operations](fork-operations.md) | 2026-07-23 build session, 2026-11-08 documentation round, deployment gap | Reconstructing what the fork actually did |
| [2026-07-23 build evidence](../evidence/2026-07-23-fork-build/README.md) | Tool versions, build variants, artifacts, logs | Auditing the fork build |
| [2026-11-08 local build](../evidence/2026-11-08-local-build.md) | Current compile verification | Checking the latest build |
| [Deployment runbook](../modules/deployment/README.md) | Future deployment procedure and record template | Preparing a similar clock |
| [Factory firmware](../modules/factory-firmware/README.md) | Inherited factory dump and original UI | Before restoring or replacing factory firmware |

## 3. What not to infer

- The upstream screenshots show a working deployment of the upstream firmware. They are **not** evidence of the fork's unit, image or configuration.
- The 2024 release binaries and factory dump predate the 2026 fork. Their presence in the fork does not mean the fork built or deployed them.
- The 2026-07-23 build session proves the fork could compile the upstream source; it does **not** prove a flash, a boot, or a deployment.
- No fork-specific deployment date, flash offset, serial log or configuration has been found. The maintainer reports a real deployment; those details remain **待核实** in `docs/DEVELOPMENT.md` §5.

## 4. History maintenance

- New fork-local operations go to `docs/history/fork-operations.md` and, when raw evidence exists, `docs/evidence/<date>-<task>/`.
- Do not rewrite upstream history or copy upstream commit narratives as fork work.
- Do not close an unknown deployment or a failed/not-run test by reorganising this page.
- Historical evidence records what was observed then; it does not create a current qualification. Current qualifications are in `docs/VALIDATION.md`.
