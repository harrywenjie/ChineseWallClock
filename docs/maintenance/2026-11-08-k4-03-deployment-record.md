# 2026-11-08 K4-03 部署记录补充

## 1. 范围与边界

- **日期：** 2026-11-08。
- **基线：** 仓库 `6eed13a`（上一轮文档迁移），fork `master`。
- **触发：** maintainer 提供实际 K4-03 刷写的 Codex chat log，要求把真实步骤留给未来复现。
- **范围：** 新增 curated deployment record，更新入口、validation、history、deployment、hardware、build、factory-firmware、firmware 配置/时间/显示页面、README 和 AGENTS。
- **非目标：** 不改 code、依赖、build、flash、hardware 或 upstream merge；不声称超出 supplied log 的完整 hardware compatibility。

## 2. 来源与出处

- 来源是 maintainer 提供的 Codex session log；部署日期为 **2026-07-23**，由 maintainer 后来确认。Chat 显示 shell 时间 14:52。
- Log 覆盖刷前 audit、build、批准、esptool write、自动 + 独立 verify、首次 boot、Web UI、配置修改和 Wi-Fi 保留。
- Raw chat log 不提交；公开记录是 [2026-07-23 K4-03 deployment](../evidence/2026-07-23-k4-03-deployment.md)。
- 公开记录省略：MAC、SSID、LAN 地址、AP chip suffix、私有 backup path。K4-03 factory backup 含已保存的 Wi-Fi 配置（SSID 在 SDK 区确认），绝不进入 Git。
- 保留：实际机器 **K4-03**、ESP8266EX、26 MHz、4 MB、`COM3` 上的 CP210x；backup 4,194,304 bytes，SHA-256 `59FC45E91B37DCAD5C4E60E90416E3351D303A7CB8739B791CBD999FDC0CA37E`；image 485,280 bytes，SHA-256 `5E4F281421DCE894FED3F03DD9599AF8A690218A85C70B6A5A5DB466748D3D1D`；esptool 5.3.1；offset `0x000000`；无 full erase；verification 通过。

## 3. 映射与处置

| 位置 | 变更 |
|---|---|
| `docs/evidence/2026-07-23-k4-03-deployment.md` | 新增 curated record：hardware、backup、build、flash、verify、脱敏 boot log、config、Wi-Fi 保留、剩余测试 |
| `docs/DEVELOPMENT.md` | 实际部署替代“待核实”；更新 validation/baseline/next task |
| `docs/VALIDATION.md` | deployment software path PASS；hardware compatibility PARTIAL；可复现 build 状态 |
| `docs/history/fork-operations.md` | 时间线、实际机器、deterministic build、部署摘要、剩余缺口 |
| `docs/modules/deployment/README.md` | 记录 K4-03 部署表和 unit-specific flash 说明 |
| `docs/modules/hardware/README.md` | K2-02 vs K4-03、实际 UART/header 接线、GPIO15 风险 |
| `docs/modules/build-and-flash/README.md` | 实际 build 参数、`SOURCE_DATE_EPOCH`、最终 hash、K4-03 flash setup |
| `docs/modules/factory-firmware/README.md` | K4-03 per-unit backup 和 restore caveat；upstream K2-02 dump 不是替代 |
| `docs/modules/firmware/configuration.md` | 观察到 first-boot default 和 `Pacific/Auckland` 配置 |
| `docs/modules/firmware/time.md` | `Pacific/Auckland`/`nz.pool.ntp.org` 和 TZDB caveat |
| `docs/modules/firmware/display.md` | K4-03 初次目视和 GPIO15/OE reset 风险 |
| `docs/modules/firmware/README.md` | 实际 K4-03 部署指针 |
| `README.md`、`AGENTS.md` | 实际 K4-03、部署链接、私有 backup/脱敏约束 |
| `docs/maintenance/2026-11-08-docs-migration.md` | 指向本记录；历史状态保留 |

## 4. 保全与隐私

- 原始 chat log 不提交；它含私有网络标识和 full-flash backup hash/path。
- Curated record 保留操作步骤、hash、命令和 boot-log 行为，同时用 placeholder 替换私有值。
- K4-03 backup 没有被修改；size/hash 记录在案，文件留在仓库外。
- Upstream K2-02 `factory_firmware/image4M.bin` 未动，并明确标记为不是 K4-03 恢复镜像。
- 没有改写历史让部署看起来更早；新记录有日期和链接。

## 5. 验证

- **链接/anchor：** tracked Markdown 的 Python checker；当时 **165 个本地链接，0 broken**。
- **容量（LF 源码字符）：** 入口 **7,968**（limit 8,000）；design **3,960**（4,000）；validation **3,995**（4,000）；firmware overview **6,000**（6,000）；display **5,942**（6,000）；hardware **5,986**（6,000）；factory **5,989**（6,000）；time **4,345**；configuration **9,428**、build-and-flash **8,754**、deployment **10,549**、fork operations **8,976**。后四个是 detailed contract/runbook/history，不是 navigation index；记录 size，供下次 review。
- **静态检查：** `git diff --check` 交付前运行；无 code/dependency change。
- **证据边界：** deployment software path 基于 supplied chat log；详细 display/RTC/brightness 仍 partial。本轮没有访问时钟或私有 backup。
- **产品资格：** 文档不产生新 hardware qualification；部署是一台 observed unit，不证明 K2-02/K4-03 等价。

## 6. 后续

- 继续 hardware checks：display segments/ghosting、秒点 LED、RTC offline retention、auto-brightness polarity、OTA、断网 watchdog、power-cycle persistence。
- 如果找回原始 session，可记录准确的部署时间。
- 私有 K4-03 backup 离线保存；restore 前验 hash。
- 不要把 upstream K2-02 factory image 当 K4-03 restore image。
- **下一任务：** `VAL-2026-11` — 已部署机器的 hardware checklist；这是记录，不是执行授权。
- **交付：** deployment record commit `ec6507f`，2026-11-08 push 到 `origin/master`；delivery note 在后续 commit 修正。
- **已被替代：** 确认日期、硬件准备、backup 处理和人工测试结果在 [hardware and tests record](2026-11-08-k4-03-hardware-and-tests.md) 更新；本记录其余部分保持历史。
