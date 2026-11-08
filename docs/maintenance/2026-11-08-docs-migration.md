# 2026-11-08 文档迁移记录

## 1. 范围与边界

- **日期：** 2026-11-08。
- **基线：** fork `harrywenjie/ChineseWallClock` 的 `d55188e`（upstream HEAD，2025-07-25）；迁移前 working tree clean；没有 fork commit/push。
- **触发：** 仓库没有统一开发入口、没有项目 `AGENTS.md`；fork 本地 build/deployment 记录只在 ignored `temp/`。Maintainer 要求文档规范化和 fork 操作记录保存。
- **范围：** README、`AGENTS.md`、`docs/DEVELOPMENT.md`、design/validation 导航、firmware/hardware/build/deployment/factory module、history 和 evidence、本维护记录。
- **非目标：** 不改 firmware/code、不升级依赖、不 merge upstream、不刷写、不部署、不发布 release。

## 2. 迁移前状态

- **旧入口：** 无。`README.md` 是唯一叙述文档，承载产品摘要、功能 checklist、硬件、开发环境、UI 截图、factory firmware 和贡献说明。
- **并行当前状态文档：** 无（没有 TODO/ROADMAP/STATUS/HANDOFF）。
- **文档资产：** `docs/datasheets/`（PDF）、`docs/display/`（ODS/照片）、`docs/images/`（设备、UI、factory 截图）、`KiCad/schematic.pdf`、`releases/`、`factory_firmware/`、`libraries/libraries.zip`。
- **Fork 本地记录：** `temp/`（ignored）有 2026-07-23 toolchain/build session、build log、artifact、PDF virtualenv 和 rendered schematic。
- **未决项：** 未正式跟踪；README unchecked items 和缺失的 deployment record 是事实上的 open list。
- **容量基线：** 没有 entry/design/validation 页面；README 4,415 bytes。

## 3. 映射与处置

| 原位置 | 分类 | 处置 | 新位置 |
|---|---|---|---|
| README title、warranty、Buy Me a Coffee、blog link | 公开导航/介绍 | 重写，保留链接 | `README.md` |
| README Summary（为什么替换 factory firmware） | 产品意图 | 移动 | `README.md` 介绍；[factory firmware](../modules/factory-firmware/README.md) |
| README feature checklist（`[x]`） | 当前功能合同 | 移动；不再作为 README 状态 | [firmware overview](../modules/firmware/README.md) |
| README unchecked items（`[ ]`） | 未完成产品项 | 移到唯一 open-items 表；不关闭 | `docs/DEVELOPMENT.md` §5 |
| README The Device/Hardware | 设计/硬件 | 移动 | [hardware](../modules/hardware/README.md) |
| README 编程 header、AP 名/密码、first boot | 设计/硬件/部署 | 移动 | [hardware](../modules/hardware/README.md)、[deployment](../modules/deployment/README.md)、[configuration](../modules/firmware/configuration.md) |
| README development environment | Build 合同 | 移动 | [build and flash](../modules/build-and-flash/README.md) |
| README UI 截图 | 参考媒体 | 保留路径；从 firmware/hardware 链接 | `docs/images/` |
| README factory-firmware 段和截图 | 硬件/证据 | 移动 | [factory firmware](../modules/factory-firmware/README.md) |
| README contribution | 导航/约束 | 重写 | `README.md`、`AGENTS.md`、`docs/DEVELOPMENT.md` §4 |
| `docs/datasheets/`、`docs/display/`、`docs/images/`、`KiCad/` | 二进制参考媒体 | 原路径保留并链接 | 同路径 |
| `libraries/README.md`、`libraries/libraries.zip` | Build 约束/backup | 保留并链接 | 同路径；[build and flash](../modules/build-and-flash/README.md) |
| `releases/` | Inherited artifacts | 保留；记录 hash | 同路径；[validation](../VALIDATION.md) |
| `factory_firmware/image4M.bin` | Inherited evidence | 保留；记录 caveat | 同路径；[factory firmware](../modules/factory-firmware/README.md) |
| `temp/logs/`、`temp/artifacts/`、`temp/arduino-cli.yaml`、`temp/render_schematic.py`、`temp/downloads/` checksums | Fork 本地操作/证据 | 复制到 evidence；原件留 `temp/` | [2026-07-23 fork build](../evidence/2026-07-23-fork-build/README.md) |
| 2026-11-08 fresh compile | Validation 证据 | 新增 | [2026-11-08 local build](../evidence/2026-11-08-local-build.md) |
| 新 entry | 当前状态 | 新增 | `docs/DEVELOPMENT.md` |
| 新项目约束 | 稳定约束 | 新增，保持薄 | `AGENTS.md` |
| 新 design/validation 导航 | 导航 | 新增 | `docs/ENGINEERING_DESIGN.md`、`docs/VALIDATION.md` |
| 新 deployment runbook | 合同/runbook | 新增 | [deployment](../modules/deployment/README.md) |
| 新 history/provenance | 历史 | 新增 | `docs/history/README.md`、`docs/history/fork-operations.md` |

## 4. 保全与去重

- **旧 README：** Git `d55188e` 保留旧版本；它被替换，没有保留第二入口。没有 verbatim snapshot 文件，因为内容映射到上面的页面，旧 revision 在 Git 中不可变。
- **Upstream vs fork：** 迁移明确记录 fork 来源，不把 upstream commit、截图、release 或 factory dump 说成 fork 工作。没有重写 upstream history。
- **Artifacts：** `releases/` 和 `factory_firmware/` 未修改；size/SHA-256 记录在 [validation](../VALIDATION.md) 和 [artifact manifest](../evidence/2026-07-23-fork-build/artifacts.sha256)。
- **Temp 记录：** raw build log、CLI config、schematic script、checksum 和 manifest 原样复制；绝对路径指向原 workspace。原件仍在 `temp/`，不提交。`.gitattributes` 把复制 `.log` 标为 `-whitespace`，避免 console 格式空格触发 `git diff --check`；内容未改。
- **Anchor/link：** 旧 README 没有 heading anchor。新增稳定 anchor：`release-rebuild`、`hardware-and-deployment`、`known-implementation-notes`、`known-persistence-defects`、`provenance`、`3-phase-1-full-factory-backup`、`record-template`；inbound/outbound 本地链接已检查。
- **通用规则：** 文档/session/Git 规则引用适用全局 `AGENTS.md` 和 skills；没有把全局规则正文复制进项目。
- **未决项：** README unchecked 功能、缺失的 deployment record、exact-rebuild unknown、hardware not-run 保持 open/unknown；迁移没有关闭。

## 5. 验证

- **链接/anchor：** 所有 tracked Markdown（排除 `temp/` 和复制的 raw-log 目录）用 Python checker 检查；**当时 141 个本地链接，0 broken**。
- **容量（LF 源码字符）：** 入口 **7,931**（limit 8,000）；design **3,935**（4,000）；validation **3,996**（4,000）；module 导航：firmware **5,744**、hardware **5,490**、factory **5,072**（limit 6,000）；history 3,128。`configuration.md` 8,453、`build-and-flash/README.md` 7,269、`deployment/README.md` 8,222、`fork-operations.md` 6,679 是 detailed contract/history，不是 navigation index；记录 size，供下次 review。
- **阅读走查：** 入口 §7 一步到 [deployment record template](../modules/deployment/README.md#record-template)；入口 §5 一步到非当前 hardware/validation 证据。Module 页面链接直接合同并回入口。
- **静态检查：** 上述 link checker；`git diff --check` 在交付前运行；没有 code/dependency change。
- **Build 证据：** 2026-11-08 按 documented toolchain compile pass；见 [2026-11-08 local build](../evidence/2026-11-08-local-build.md)。没有新增 hardware/deployment 资格。

## 6. 后续

- **Open/unknown：** K4-03 部署记录 **待核实**（当时）；v1.1 exact rebuild **UNKNOWN**；hardware **NOT_RUN**；Web UI upload **OPEN/FAILED**；持久化缺陷 **OPEN**；upstream 分叉 **OPEN**。
- **下一任务：** `DEP-2026-11` — 记录实际部署并在 spare ESP8266/D1 mini 上 dry-run；backup 验证前不要刷时钟。这是记录，不是执行授权。
- **下次触发：** 新部署记录、容量预警、焦点变化、firmware 变化或 maintainer 请求。入口接近 8,000 warning；新增 open item 应替换或合并现有行。
- **交付：** 文档迁移 commit `92772d1`，2026-11-08 push 到 `origin/master`。
- **已部分被替代：** 部署状态在 2026-11-08 由 [K4-03 deployment record](2026-11-08-k4-03-deployment-record.md) 和 [curated evidence](../evidence/2026-07-23-k4-03-deployment.md) 更新；本记录其余部分保持历史。
- **temp 处置已更新：** §3/§4 的“原件留 `temp/`”是当时状态。2026-11-08 盘点把 checker 迁到 [`scripts/check_docs.py`](../../scripts/check_docs.py)，大包按 [toolchain setup](../modules/build-and-flash/toolchain-setup.md) 重建，`temp/` 不再是唯一副本；详见 [temp inventory](2026-11-08-temp-inventory.md)。
- **备注：** 文档语言原为 English，后按 maintainer 要求在 2026-11-08 改为中文；二进制媒体保留原路径；fork 落后 upstream；没有改代码、libraries、releases 或 hardware。
