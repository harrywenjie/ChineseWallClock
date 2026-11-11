# ChineseWallClock — 开发入口

这是唯一的当前状态和下一任务入口。先读 §1、§2、§5、§7，按 §3 核对本轮范围，再按阅读条件进入相关章节。其他 design、validation、module、history 页面都不是默认全文必读。

## 1. 当前快照

**目标：** 保持固件可构建，并维护一套有证据支撑的 fork K4-03 构建/部署记录。当前没有活跃的固件功能开发。

**非目标：** 改固件行为、升级依赖、打开或刷写时钟、merge upstream、发布 release。

**当前焦点：** `DEP-2026-11-11` — 第二台 K4-03 刷写、刷后检查和部署记录。

**最近验证：** 2026-07-23 首台 K4-03 部署 **PASS**（build/flash/verify/boot/config/Wi-Fi/AP；断网恢复为人工反馈）— [记录](evidence/2026-07-23-k4-03-deployment.md)；2026-11-08 compile **PASS**（485,280 bytes，IRAM 95 %）— [build](evidence/2026-11-08-local-build.md)；同轮脚本在空 `temp/` 副本（`E:\cwc\ChineseWallClock`）全量下载并重建部署 image **PASS**（485,280 bytes，`5E4F…D3D1D`）— [toolchain setup](modules/build-and-flash/toolchain-setup.md)；2026-11-11 第二台 K4-03 flash/verify/boot/Web UI **PASS**，maintainer 手动配置后反馈正常 — [第二台记录](evidence/2026-11-11-k4-03-second-unit-deployment.md)。自动亮度偏暗，已改用固定亮度；display/RTC 细节仍为 partial。

**部署基线：** 两台 K4-03：#1 2026-07-23，使用时钟自身 USB-A；#2 2026-11-11，实际使用 CP210x 5V 单电源（见记录 caveat）。两台均刷同一 firmware `5E4F…`（485,280 B），esptool 5.3.1，`0x000000`，均已 verify；inherited v1.1（485,248 B）是 upstream，不是本 fork 部署。

**当前阻塞：** display/RTC 的细化结果和自动亮度根因尚未记录；第二台只有 maintainer 人工反馈“一切正常”，没有逐项测试。

## 2. 权威资料与阅读条件

| 需要什么 | 读哪里 | 阅读条件 |
|---|---|---|
| upstream 意图、inherited release/factory 资产 | [`README.md`](../README.md)、[`history/README.md`](history/README.md) | 需要来源或原始意图时 |
| fork 本地操作和 build 证据 | [`history/fork-operations.md`](history/fork-operations.md)、[`2026-07-23 build`](evidence/2026-07-23-fork-build/README.md) | 重建 build 记录时 |
| 首台 K4-03 部署（2026-07-23） | [`2026-07-23 deployment`](evidence/2026-07-23-k4-03-deployment.md) | 复现首台 flash/boot/config 时 |
| 第二台 K4-03 部署（2026-11-11） | [`2026-11-11 second unit`](evidence/2026-11-11-k4-03-second-unit-deployment.md) | 复现第二台 flash/boot/Web UI、查看供电 caveat 时 |
| 固件行为 | [`modules/firmware/README.md`](modules/firmware/README.md) | 修改固件前 |
| 硬件、pinout、schematic、datasheet | [`modules/hardware/README.md`](modules/hardware/README.md) | 接线、刷写或恢复前 |
| build、image、offset、OTA | [`modules/build-and-flash/README.md`](modules/build-and-flash/README.md) | compile/flash 前 |
| 丢弃 temp 后重建 toolchain/libraries | [`modules/build-and-flash/toolchain-setup.md`](modules/build-and-flash/toolchain-setup.md) | 新机器、清理 temp 或 build 环境不完整时 |
| 端到端部署 | [`modules/deployment/README.md`](modules/deployment/README.md) | 打开/刷写时钟前 |
| validation 资格 | [`VALIDATION.md`](VALIDATION.md) | 声称某功能可用时 |
| factory backup 和原厂 UI | [`modules/factory-firmware/README.md`](modules/factory-firmware/README.md) | 恢复/替换原厂固件前 |
| 文档链接/容量检查 | [`scripts/check_docs.py`](../scripts/check_docs.py) | 每次改文档后 |
| 文档维护绑定 | §4、[`AGENTS.md`](../AGENTS.md) | 每次改文档 |
| 全局 agent 规则 | 适用的全局 `AGENTS.md`（DSH §6） | 每一轮；不要复制正文到这里 |

## 3. 当前工作包与通过条件

- **任务：** `DEP-2026-11-11`。
- **范围：** 记录第二台 K4-03 的原厂 backup、build/image、flash、verify、boot/Web UI 和 maintainer 手动配置反馈；更新入口、validation、history、hardware/deployment 和导航。
- **通过条件：** 记录区分 flash/verify/boot/网络/人工反馈；私有 SSID、LAN IP、MAC、AP suffix 和 backup path 不进入 Git；链接/anchor 有效；容量在预警内；`git diff --check` 干净；没有代码、依赖或固件源码变更。
- **边界：** 只记录已经发生的部署；不重刷、不做 restore、不把 raw backup 或 raw serial log 提交进仓库。实际刷写已经完成，本轮不是新的刷写授权。

## 4. 每轮开发与收尾

- 遵循适用的全局 `AGENTS.md` 流程。本节只记录项目命令和环境。
- **文档维护绑定：** 分层、容量、复审、退出和未决项规则见全局 `AGENTS.md` §6 和 `doc-governance` skill。不要在这里复制规则正文。
- **项目文档规则：** 中文；命令/路径/代码标识符/状态值保留英文；二进制媒体留在 `docs/datasheets/`、`docs/display/`、`docs/images/`、`KiCad/`、`releases/`、`factory_firmware/`；fork 操作记录放 `docs/history/fork-operations.md`；原始证据放 `docs/evidence/`；维护记录放 `docs/maintenance/`。
- **来源：** tracked history 是 upstream history。不要把 upstream commit、截图、release 或 factory dump 说成 fork 的工作。fork 本地 build 环境在 `temp/`（可整体删除，重建见 [toolchain setup](modules/build-and-flash/toolchain-setup.md)），永久证据在 `docs/evidence/`；两台 K4-03 的部署记录分别是 `docs/evidence/2026-07-23-k4-03-deployment.md` 和 `docs/evidence/2026-11-11-k4-03-second-unit-deployment.md`。
- **验证边界：** compile/文档检查是 local；hardware、NTP/WiFi、display、OTA、Web UI 和 deployment 是不同证据等级。

## 5. 决定与未决事项

| 项目 | 状态、影响与下一步 | 详情 |
|---|---|---|
| K4-03 硬件兼容性 | **PARTIAL** — 两台 software/network 通过；第二台手动配置后人工反馈正常；display 细节、自动亮度根因和第二台逐项测试未记录；固定亮度 workaround。下一步：验证。 | [首台记录](evidence/2026-07-23-k4-03-deployment.md)、[第二台记录](evidence/2026-11-11-k4-03-second-unit-deployment.md) |
| Web UI firmware upload | **OPEN** — upstream 报告 broken，本 fork 未复现。复现后再修或记录 serial/OTA workaround。 | [firmware notes](modules/firmware/README.md#known-implementation-notes) |
| 持久化缺陷 | **OPEN** — `clever` 不保存；parse/mount 失败不回退默认值。先在 hardware 上验证。 | [configuration](modules/firmware/configuration.md#known-persistence-defects) |
| v1.1 精确重建 | **UNKNOWN** — 当前源码可用固定 epoch 复现，但 485,280 B 比 v1.1 的 485,248 B 大 32 B；不能声称 byte-identical。 | [validation](VALIDATION.md#release-rebuild) |
| upstream 分叉 | **OPEN** — fork HEAD `d55188e`（2025-07-25）；upstream 有更新提交（2026-09-05 push）；尚未决定 merge/sync。 | [provenance](history/README.md#provenance) |
| 时区下拉、UI 密码、MQTT | **OPEN** — inherited upstream 功能缺口，无承诺或排期。 | [firmware](modules/firmware/README.md#open-product-items) |

未决项不会因为整理文档而关闭。`UNKNOWN`、`FAILED`、`NOT_RUN` 和暂停的决定保持原状态，直到有新证据或 maintainer 明确决定。

## 6. 命令与验证边界

| 命令 | 用途 | 边界 |
|---|---|---|
| `pwsh -NoProfile -File scripts/setup-build-env.ps1` | 下载/校验 Arduino CLI、安装 core、解压 libraries 到 `temp/` | 需要网络；不碰硬件 |
| `pwsh -NoProfile -File scripts/build-firmware.ps1 -Variant canonical1 -Clean` | 用固定 FQBN/libraries/build property/epoch 编译并比对部署 hash | 仅 local compile |
| `python scripts/check_docs.py` | 检查本地 Markdown 链接/anchor 并报告容量 | 仓库卫生 |
| `git diff --check` | 检查空白/冲突 | 仓库卫生 |

- **环境：** Windows 11、Arduino CLI 0.35.3、ESP8266 core 3.1.2、bundled libraries；临时环境可删除和重建（[toolchain setup](modules/build-and-flash/toolchain-setup.md)）。原作者使用 Ubuntu 22.04.4、Arduino IDE 2.3.2、Wemos D1 mini 测试板。
- **未覆盖：** 详细 K4-03 display/RTC/brightness 检查、第二台逐项硬件测试、OTA upload、Web UI upload、power loss、长期漂移、断网下的 watchdog。build/flash/verify/boot/Web UI 已由两份 deployment record 覆盖；首台还覆盖 config/Wi-Fi/AP/断网恢复。

## 7. 当前交接与下一任务卡

<a id="current-next"></a>

**当前安全点：** `DEP-2026-11-11` 完成；第二台 K4-03 已刷同一 image，flash/verify/boot/Web UI 通过；maintainer 手动配置后反馈正常；详细硬件测试仍 partial。

**未验证：** 第二台详细 display/RTC/auto-brightness、OTA upload、Web UI upload、power-loss、restore；离线重建仍 **NOT_RUN**。

**最小输入：** `AGENTS.md`、本入口 §1/2/5/7、[第二台记录](evidence/2026-11-11-k4-03-second-unit-deployment.md)、[首台记录](evidence/2026-07-23-k4-03-deployment.md)、[toolchain setup](modules/build-and-flash/toolchain-setup.md) 和对应 module 文档。

**下一候选：** `VAL-2026-11` — 在两台已部署时钟上跑 hardware checklist（段位、RTC retention、自动亮度、OTA）；记录结果；除非失败，不要重刷。

**通过条件：** 记录观察、log 和失败；更新本入口 §1/§5 与 `docs/VALIDATION.md`，并区分人工反馈和逐项测试。重刷必须有新的明确批准和对应 unit 的 backup hash 复核；不要用首台 backup restore 第二台。删除 `temp/` 后再 build 时，先按 toolchain setup 重建并复核 image hash。

**不扩展：** upstream merge、功能开发、依赖升级、release 发布，或未经明确授权打开/刷写时钟。

**授权边界：** 下一任务卡是记录，不是执行授权。maintainer 最新的暂停、拒绝或项目边界优先。
