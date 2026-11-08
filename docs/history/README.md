# 历史与来源

本页是项目历史索引，区分 **upstream 历史** 和 **fork 本地操作**。fork 没有改固件源码，只有文档提交。

<a id="provenance"></a>

## 1. 来源

| 项目 | 值 |
|---|---|
| Upstream | [`halacs/wallclock`](https://github.com/halacs/wallclock) |
| Fork | [`harrywenjie/ChineseWallClock`](https://github.com/harrywenjie/ChineseWallClock) |
| Fork 创建 | 2026-01-27T20:03:16Z（GitHub API） |
| 本地 clone | 2026-07-23 14:08:33 +12:00，从 fork remote |
| Tracked HEAD | `d55188e`（2025-07-25），与 `origin/master` 一致 |
| Fork 提交 | 只有文档提交；没有固件源码变更 |
| Upstream 分叉 | upstream 有 2026-09-05 push 的新提交，本 fork 未 merge |

Tracked source 是 upstream 工作。`releases/`、`factory_firmware/`、`docs/images/`、`docs/display/`、`docs/datasheets/`、`KiCad/` 是 inherited 资产。fork 本地 build 工作原在 `temp/`，保留部分在 [`docs/evidence/2026-07-23-fork-build/`](../evidence/2026-07-23-fork-build/README.md)。`temp/` 可整体删除；重建见 [toolchain setup](../modules/build-and-flash/toolchain-setup.md)，脚本在 [`scripts/`](../../scripts/README.md)。实际 K4-03 部署单独记录在 [`docs/evidence/2026-07-23-k4-03-deployment.md`](../evidence/2026-07-23-k4-03-deployment.md)。

## 2. 索引

| 页面 | 内容 | 何时读 |
|---|---|---|
| [Fork operations](fork-operations.md) | 2026-07-23 build/deployment 和 2026-11-08 文档轮 | 重建 fork 实际做过什么 |
| [2026-07-23 build evidence](../evidence/2026-07-23-fork-build/README.md) | tool 版本、build 变体、artifact、log | 审计 fork build |
| [2026-07-23 K4-03 deployment](../evidence/2026-07-23-k4-03-deployment.md) | 实际 flash、verify、首次 boot、config、Wi-Fi 保留 | 复现或审计部署 |
| [2026-07-23 hardware preparation](../evidence/2026-07-23-k4-03-hardware-preparation.md) | 焊接、串口/GND 排查、针脚确认、下载模式 | 准备另一台机器 |
| [2026-07-23 backup manifest](../evidence/2026-07-23-k4-03-backup-manifest.md) | 私有 full-flash backup、内容检查、restore 预案 | 恢复或讨论 backup 前 |
| [2026-11-08 local build](../evidence/2026-11-08-local-build.md) | 当前 compile 验证 | 检查最新 build |
| [Deployment runbook](../modules/deployment/README.md) | 未来部署流程和 record template | 准备类似时钟 |
| [Factory firmware](../modules/factory-firmware/README.md) | Inherited factory dump 和原厂 UI | 恢复/替换原厂固件前 |

## 3. 不要推断

- upstream 截图展示的是 upstream 固件的一次部署，**不是**本 fork 机器、image 或配置的证据。
- 2024 release binaries 和 factory dump 早于 2026 fork；它们在 fork 里不代表 fork build 或部署过。
- 2026-07-23 build 证明 fork 能编译 upstream 源码；flash、boot、部署由单独的 [K4-03 deployment](../evidence/2026-07-23-k4-03-deployment.md) 记录；两者都不证明完整 hardware compatibility。
- 实际部署是一台 K4-03，不证明 K2-02/K4-03 等价，也不关闭 `docs/DEVELOPMENT.md` §5 中未测的 display/RTC/brightness 项。

## 4. 历史维护

- 新的 fork 操作写 `docs/history/fork-operations.md`；有原始证据时放 `docs/evidence/<date>-<task>/`。
- 不重写 upstream 历史，不把 upstream commit 叙述成 fork 工作。
- 不通过重新整理关闭 failed/not-run test 或 partial hardware check。
- 历史证据只记录当时观察到的事实，不产生当前资格；当前资格在 `docs/VALIDATION.md`。
