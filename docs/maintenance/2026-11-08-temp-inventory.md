# 2026-11-08 temp 盘点与备份记录

## 1. 范围与基线

- **日期：** 2026-11-08。
- **基线：** `master` 的 `e4ad560`；本轮开始时 working tree clean，remote 同步。
- **触发：** maintainer 要求盘点 ignored `temp/`，把重要脚本/文档备份进 Git，并把大包的下载/重建步骤写进文档；目标是 `temp/` 删除后仍能重建部署所需环境。
- **范围：** 盘点时 `temp/` 的 12 个子目录和根文件；`scripts/` 新增工具；build/toolchain 文档；入口、AGENTS、module、history、evidence 中的 temp 引用。
- **非目标：** 本轮不删除整个 `temp/`、不改固件/依赖、不刷写、不部署、不 merge upstream、不发布 release。
- **盘点总量：** 基线 27,925 files，约 **1.63 GB**（含本轮临时 test config；`arduino-data`、`build`、`pdf-venv` 占大部分）。

## 2. 盘点与处置

| `temp/` 项 | 大小/文件 | 内容 | 处置 |
|---|---|---|---|
| `arduino-data/` | 425.5 MB / 3,697 | ESP8266 core 3.1.2、core tools、package index、Arduino builtin tools；CLI data dir | 不提交；`setup-build-env.ps1` 重建。版本/URL/hash 见 [toolchain setup](../modules/build-and-flash/toolchain-setup.md)。 |
| `arduino-downloads/` | 126.5 MB / 10 | core/tool 下载缓存（core zip、xtensa gcc、mkspiffs、mklittlefs、python3 等） | 不提交；按 index 重新下载。 |
| `artifacts/` | 76.2 MB / 21 | `canonical1/2`、`default`、`repro2`、`ide232-cli`、`docs-verify` 的 bin/elf/map | Binary 不提交；size/hash 已在 [fork build evidence](../evidence/2026-07-23-fork-build/README.md) 和 [local build](../evidence/2026-11-08-local-build.md)。可由 build 脚本重建。 |
| `build/` | 812.9 MB / 19,021 | 每个 variant 的 Arduino build tree、generated source | 不提交；`build-firmware.ps1` 重建。 |
| `bundled/` | 45.5 MB / 3,447 | `libraries/libraries.zip` 解压结果；18 个库 | 不提交；从 tracked zip 解压。逐文件对比为 0 modified（2026-07-23）。 |
| `docs-migration/` | 2 files / 约 10 KB | `check_docs.py` 和已消费的 2026-11-08 会话交接 | Checker 迁移到 [`scripts/check_docs.py`](../../scripts/check_docs.py)；交接内容已在入口/maintenance，按规则不提交，临时副本删除。 |
| `downloads/` | 35.1 MB / 4 | Arduino CLI 0.35.3 / 1.5.1 zip、Arduino IDE 2.3.2 source zip、CLI checksums | 0.35.3 由 setup 脚本重新下载并校验；1.5.1 和 IDE source 未参与保留 build，不需要；checksums 已在 evidence。 |
| `ide-source-2.3.2/` | 15.6 MB / 602 | Arduino IDE 2.3.2 source tree | 不提交；build options 已记录在 [`build-options.tsv`](../evidence/2026-07-23-fork-build/build-options.tsv)，重建不需要 source。 |
| `logs/` | 0.8 MB / 3 | `build-default.log`、`build-canonical-ide232-cli.log`、`docs-verify.log` | 三份都与 `docs/evidence/` 副本 byte-identical（SHA-256 相同），不再重复提交。 |
| `pdf-venv/` | 65.5 MB / 1,108 | Python 3.12 venv，PyMuPDF 1.26.3、pypdf 6.1.1 | 不提交；按 [toolchain setup](../modules/build-and-flash/toolchain-setup.md) §3 用 pip 重建。 |
| `pdfs/` | 1.6 MB / 3 | `KiCad/schematic.pdf` 的 300 dpi 页面和 600 dpi detail crops | 不提交；tracked PDF + [`render_schematic.py`](../evidence/2026-07-23-fork-build/render_schematic.py) 可重建。 |
| `toolchain/` | 66.1 MB / 4 | Arduino CLI 0.35.3 和 1.5.1 解压后的 exe/license | 0.35.3 由 setup 脚本重建；1.5.1 不需要。 |
| `arduino-cli.yaml` | 284 B | 2026-07-23 local CLI config，absolute `temp/` 路径 | 已在 evidence（byte-identical）；新增可移植 [`scripts/arduino-cli.yaml`](../../scripts/arduino-cli.yaml)。 |
| `render_schematic.py` | 1,430 B | PyMuPDF/pypdf 渲染脚本 | 已在 evidence（byte-identical）；不重复提交。 |
| `arduino-cli.reltest.yaml` | 225 B | 本轮验证相对路径的临时文件，不属于原盘点 | 删除。 |

盘点结论：唯一尚未进入 Git 的项目脚本是 `check_docs.py`；它已迁移。其余脚本/日志/config 要么已在 evidence，要么是派生文件或可下载包。`temp/` 删除不会丢失唯一的部署输入。

## 3. 本轮新增的永久备份

| 文件 | 内容 |
|---|---|
| [`scripts/check_docs.py`](../../scripts/check_docs.py) | 本地 Markdown 链接/anchor 检查和容量报告；从脚本位置解析 repo root。 |
| [`scripts/arduino-cli.yaml`](../../scripts/arduino-cli.yaml) | 可移植 CLI config；相对 `temp/` 路径从仓库根解析（Arduino CLI 0.35.3 已实测）。 |
| [`scripts/setup-build-env.ps1`](../../scripts/setup-build-env.ps1) | 下载/校验 CLI，安装 core，解压 libraries；幂等，不改硬件。 |
| [`scripts/build-firmware.ps1`](../../scripts/build-firmware.ps1) | 固定 FQBN/libraries/build property/epoch 的 compile；打印 size/hash 并比较部署 image。 |
| [`scripts/README.md`](../../scripts/README.md) | 脚本导航。 |
| [toolchain setup](../modules/build-and-flash/toolchain-setup.md) | 大包版本、URL、SHA-256、一键/手动重建步骤和边界。 |

大包不进入 Git：CLI/core/工具链归档合计约 138 MB；core 安装后 `arduino-data/` 约 425 MB。Git 只保存下载地址、版本和 checksum。

## 4. 从零重建路径

1. `libraries/libraries.zip` 是 tracked 固定快照（12,334,448 bytes，SHA-256 `E92457AA…DD07`），core/库版本与 build property 已记录。
2. `scripts/setup-build-env.ps1` 下载并校验 Arduino CLI 0.35.3（15,548,385 bytes，SHA-256 `B3B03C37…A35C`），安装 ESP8266 core 3.1.2（39,269,515 bytes，SHA-256 `B3F47686…B182`），并从 package index 下载 xtensa gcc/mkspiffs/mklittlefs/python3。
3. `scripts/build-firmware.ps1 -Variant canonical1 -Clean` 用 `SOURCE_DATE_EPOCH=1711661163`、`build.warn_data_percentage=75` 和固定 libraries compile，输出 485,280-byte image；脚本比较 `5E4F2814…D3D1D`。
4. esptool 5.3.1 和部署步骤仍是外部依赖：`python -m pip install esptool==5.3.1`；实际刷写按 [deployment runbook](../modules/deployment/README.md)。
5. 需要网络访问 Arduino downloads、GitHub、ESP8266 package index；仓库不保存离线镜像。

## 5. 删除就绪判定

| 检查 | 结果 | 依据 |
|---|---|---|
| 源码和固定 libraries 在 Git | PASS | tracked `libraries/libraries.zip` |
| toolchain/大包下载地址和 hash | PASS | [toolchain setup](../modules/build-and-flash/toolchain-setup.md) |
| 从零安装命令可执行 | PASS（空 `temp/` 副本全量下载，见 §6） | setup/build 脚本 |
| 部署 image 可重建并比对 | PASS（空 `temp/` 副本 local compile） | §6；hash 与 2026-07-23 部署一致 |
| 私有 per-unit backup 不依赖 temp | PASS | [backup manifest](../evidence/2026-07-23-k4-03-backup-manifest.md)；原始 image 在仓库外 |
| 整个 `temp/` 已删除 | **NOT_RUN** | 本轮只清理已消费的 handoff/checker、测试 config 和测试 build 输出；整个目录删除由 maintainer 决定 |
| 离线重建 | **NOT_RUN** | 需要下载 CLI/core/tools；未做离线 mirror |

## 6. 验证

- **链接/anchor：** `python scripts/check_docs.py` 覆盖 tracked Markdown（排除 `temp/` 和 raw-log 目录）；本轮最终 **249 个本地链接，0 broken**。
- **容量：** 入口、design/validation 导航和新 toolchain 页均在预警内；具体数字见 §7。
- **Hash 对照：** `temp/logs/` 3 份、`temp/arduino-cli.yaml`、`temp/render_schematic.py` 与 evidence 副本全部 SHA-256 相同；CLI zip 和 `libraries.zip` 与记录一致。
- **Setup dry-run：** `scripts/setup-build-env.ps1` 在已有 `temp/` 上幂等通过：CLI 0.35.3、core 3.1.2、18 个库目录、esptool 5.3.1；没有下载或删除。
- **空 temp 重建：** 在 `E:\cwc\ChineseWallClock` 只复制 sketch、`libraries.zip` 和 `scripts/`，`setup` 全量下载并安装（exit 0），`build-firmware.ps1 -Variant canonical1 -Clean` exit 0，image 485,280 bytes、`5E4F…D3D1D`；证明 `temp/` 删除后可从网络重建。副本已删除；约 209 字符嵌套路径失败和 sketch 目录名规则见 [local build §8](../evidence/2026-11-08-local-build.md)。
- **Build 复现：** `scripts/build-firmware.ps1 -Variant scriptcheck -Clean` exit 0；image 485,280 bytes，SHA-256 `5E4F2814…D3D1D`，与部署 image 一致；RAM 37,404 / 80,192，IRAM 62,551 / 65,536。详见 [local build §7](../evidence/2026-11-08-local-build.md)。证明脚本和现有 toolchain 能重建部署 image；不证明硬件行为。
- **未运行：** 离线重建、flash、boot、display、Wi-Fi、OTA、power-cycle；这些仍是 **NOT_RUN** 或按原证据边界保持未验证。

## 7. 容量与未决项

| 页面 | LF 字符 | 预警 | 处置 |
|---|---:|---:|---|
| `docs/DEVELOPMENT.md` | 6,217 | 8,000 | 正常；比上轮增加本轮任务卡和 toolchain 入口 |
| `docs/ENGINEERING_DESIGN.md` | 3,083 | 4,000 | 正常 |
| `docs/VALIDATION.md` | 2,838 | 4,000 | 正常 |
| `docs/modules/build-and-flash/README.md` | 5,980 | 6,000 | 接近预警；下轮优先替换/压缩，不追加轮次摘要 |
| `docs/modules/build-and-flash/toolchain-setup.md` | 5,514 | 6,000 | 正常；详细步骤留在本页 |
| `docs/history/fork-operations.md` | 7,254 | detailed | 历史合同，不是导航；不套 6,000 预警 |

未决项保持：K4-03 display/auto-brightness **PARTIAL**、Web UI upload **OPEN**、持久化缺陷 **OPEN**、v1.1 精确重建 **UNKNOWN**、upstream 分叉 **OPEN**。本轮没有新增产品/硬件资格，也没有关闭任何未决项。`temp/` 整体删除和离线重建仍是后续动作。

## 8. 决定

| 决定 | 理由 | 影响 |
|---|---|---|
| 大包不进 Git | 体积和机器特定性；Git 只存可重建输入 | 需要网络下载；hash/URL 固定 |
| `check_docs.py` 迁到 `scripts/` 而不是复制到 evidence | 它是可复用工具，不是不可变证据 | 文档调用路径更新；原 temp 副本删除 |
| 保留已有 evidence 副本，不重复提交 log/config/script | 已 byte-identical，重复会制造两个来源 | temp 删除后仍可审计 |
| 不提交会话交接 | 交接不是第二状态入口；内容已进入口/maintenance | 临时文件可删除 |
| `scripts/arduino-cli.yaml` 用相对路径 | 可移植；0.35.3 从仓库根实测通过 | 必须从仓库根运行 |

## 9. 后续

- **Maintainer：** 确认私有 K4-03 backup 与 esptool 可用后，可删除整个 `temp/`；删除后按 [toolchain setup](../modules/build-and-flash/toolchain-setup.md) 重建。
- **未验证：** 离线重建、约 209 字符嵌套路径失败的根因、刷写/硬件。
- **下次触发：** `temp/` 删除、toolchain/library 版本变更、新部署、新证据或容量预警。
