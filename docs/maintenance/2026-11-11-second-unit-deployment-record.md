# 2026-11-11 第二台 K4-03 部署记录维护

## 1. 范围与基线

- **日期：** 2026-11-11。
- **基线：** `master` 的 `f2c7fe5`；本轮开始时 working tree clean，remote 同步。
- **触发：** maintainer 要求把第二台 K4-03 的实际刷写记录进仓库，并提交推送。
- **来源：** 2026-11-11 现场 esptool/串口输出和 maintainer 手动配置后的反馈；不是原始 chat log。
- **范围：** 新增第二台部署 evidence；更新入口、validation、history、hardware/deployment module 和 README 导航。
- **非目标：** 不改 firmware/code/依赖、不重刷、不做 restore、不提交 raw backup 或 raw serial log。

## 2. 处置

| 对象 | 处置 | 理由 |
|---|---|---|
| 第二台部署 | 新增 [evidence](../evidence/2026-11-11-k4-03-second-unit-deployment.md) | 保存 per-unit backup、flash、verify、boot/Web UI 和人工反馈的边界 |
| `docs/DEVELOPMENT.md` | 更新 §1/§2/§3/§4/§5/§6/§7 | 当前焦点变为 `DEP-2026-11-11`；部署基线改为两台；下一候选仍是 `VAL-2026-11` |
| `docs/VALIDATION.md` | 增加第二台 flash/boot/Web UI/人工反馈行 | 区分 PASS、人工反馈和未测项 |
| history | 时间线、两台机器、两份 per-unit backup、部署摘要 | 保留 fork 实际做过什么 |
| hardware/deployment module | 第二台短注、per-unit backup 警告、部署记录链接 | 读者不需要加载完整 evidence 就能看到边界 |
| `AGENTS.md`、`README.md` | 两台机器、第二台记录链接 | 稳定上下文和导航 |
| 私有数据 | 不提交 raw image/log；删除 `temp/` 串口原文 | 避免 SSID、LAN、MAC、AP suffix、backup path 进入 Git |

- **当前目标/部署基线/当前阻塞：** 两台 K4-03 均刷同一 image；第二台 flash/verify/boot/Web UI PASS；详细 display/RTC/auto-brightness 仍 partial。
- **退出必读层：** 本次串口捕获原文、临时监听脚本；不进入仓库。
- **保留按需可达：** 第二台 evidence、首台 evidence、per-unit backup 政策、未测 OTA/restore。

## 3. 容量

| 页面 | 字符数 | 预警 | 处置 |
|---|---:|---:|---|
| `docs/DEVELOPMENT.md` | 6,848 | 8,000 | 正常 |
| `docs/ENGINEERING_DESIGN.md` | 3,083 | 4,000 | 正常 |
| `docs/VALIDATION.md` | 3,527 | 4,000 | 正常 |
| `docs/modules/firmware/README.md` | 4,195 | 6,000 | 正常 |
| `docs/modules/hardware/README.md` | 4,381 | 6,000 | 正常 |
| `docs/modules/build-and-flash/README.md` | 5,980 | 6,000 | 接近预警；本轮未追加 |
| `docs/modules/build-and-flash/toolchain-setup.md` | 5,514 | 6,000 | 正常 |
| `docs/modules/factory-firmware/README.md` | 4,584 | 6,000 | 正常 |
| `docs/modules/deployment/README.md` | 7,614 | detailed | runbook，不套导航预警 |
| `docs/history/fork-operations.md` | 8,148 | detailed | 历史合同，不是导航 |

## 4. 未决项

| 项目 | 状态 | 依据 |
|---|---|---|
| 第二台详细 display/RTC/auto-brightness | **NOT_RUN / UNKNOWN** | 只有手动配置后人工反馈“正常”，没有逐项 test |
| 第二台 restore | **NOT_RUN** | backup 已验证，restore 未执行 |
| OTA upload、Web UI firmware upload | **NOT_RUN** | 只确认 OTA ready |
| 供电差异 | **记录为 caveat** | 第二台实际 CP210x 5V 单电源；不替代 runbook 的自身 USB-A 建议 |
| v1.1 精确重建、Web UI upload、持久化缺陷、upstream 分叉 | 保持原状态 | 未因本次部署关闭 |

## 5. 验证

- **链接/anchor：** `python scripts/check_docs.py`：**281 个本地链接，0 broken**。
- **容量：** 入口、validation、hardware 和 toolchain 页均在预警内；deployment/fork-operations 是 detailed 正文。
- **静态检查：** `git diff --check` 干净；没有 code/dependency/firmware source 变更。
- **证据边界：** flash/verify/boot/Web UI 是实际观察；manual config 是人工反馈；display/RTC/auto-brightness/OTA/restore 未测，不能合并为“全部通过”。

## 6. 后续

- **下一候选：** `VAL-2026-11` — 在两台时钟上跑 hardware checklist，记录逐项结果；除非失败，不要重刷。
- **如果 maintainer 提供：** 手动配置值（timezone/NTP/brightness/display options）和 display 观察，更新第二台 evidence，不改历史观察。
- **下次触发：** 新部署、restore、OTA/硬件测试、容量预警或 maintainer 要求。
