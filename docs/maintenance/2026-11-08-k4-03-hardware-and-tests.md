# 2026-11-08 K4-03 硬件与测试记录更新

## 1. 范围与边界

- **日期：** 2026-11-08。
- **触发：** maintainer 提供第二份 Codex 总结（焊接、串口/GND 排障、backup、刷后观察），并确认部署日期、断网恢复和自动亮度结果。
- **范围：** 新增 hardware-preparation 和 backup 记录，更新 deployment/validation/entry/history/module 文档，整理私有 backup 政策。
- **非目标：** 不改 code、依赖、build、flash、restore 或 hardware；原始 backup 不复制进仓库。

## 2. 来源与发现

- 部署日期由 maintainer 确认为 **2026-07-23**。
- 实际机器 **K4-03**；upstream 参考 K2-02。一台机器通过已测功能，不证明所有 K4-03 revision。
- Header 确认：pin 1 FLASH/GPIO0、pin 3 GND 确认；pin 2 未使用/可能是 RST；pin 4/5 serial pair 确认但文字记录没有最终分配 TX/RX；pin 6 +5V 确认但稳定方案不用。
- 供电/接线：clock 自己 USB-A；CP2102 自己 USB；common GND；CP2102 +5V/3V3 不接；无 RST/DTR/RTS；manual GPIO0 boot 和 `--before/after no-reset`。
- 焊接/GND 排障：时钟一度像变砖，清理并回到 minimal wiring 后恢复；没有证明具体 short。A/B/C GND 测试通过，common ground 正确。
- Backup：4,194,304 bytes，SHA-256 `59FC45E91B37DCAD5C4E60E90416E3351D303A7CB8739B791CBD999FDC0CA37E`；两次历史读取一致。内容检查在 `0x3FD010` 找到已保存 SSID，`0x3FE010` 重复；image 不是 firmware-only。Password 编码未解码。
- 刷后：Wi-Fi 配置复用、configuration AP 关闭、断网恢复；自动亮度偏暗，改用固定 manual brightness。

## 3. 映射与处置

| 位置 | 变更 |
|---|---|
| `docs/evidence/2026-07-23-k4-03-hardware-preparation.md` | 新增：焊接、串口/GND、pin 确认、下载模式、backup、auto-brightness、检查单 |
| `docs/evidence/2026-07-23-k4-03-backup-manifest.md` | 新增：私有 backup、size/hash、内容检查、restore plan、no repo copy |
| `docs/evidence/2026-07-23-k4-03-deployment.md` | 确认日期；增加 AP 关闭、断网恢复、auto-brightness workaround、hardware 链接 |
| `docs/VALIDATION.md` | 断网恢复 **PASS（人工反馈）**；auto brightness **FAILED/USABILITY**；display 细节 partial |
| `docs/DEVELOPMENT.md` | 确认日期和人工结果；当前状态/open item 增加 auto-brightness workaround |
| `docs/history/fork-operations.md`、`docs/history/README.md` | 增加 hardware preparation/backup 记录和人工反馈 |
| `docs/modules/hardware/README.md` | 增加 preparation/backup 链接；明确 pin 4/5 方向；backup 隐私 |
| `docs/modules/deployment/README.md` | 增加人工结果和 hardware-prep/backup 链接 |
| `docs/modules/factory-firmware/README.md` | 当前 verified backup 文件名；私有处理；no repo copy |
| `docs/modules/firmware/configuration.md`、`display.md`、`time.md` | 观察到的 auto-brightness 变化、display 说明、断网恢复 caveat |
| `README.md`、`AGENTS.md` | 导航、K4-03 状态、私有 backup 政策、raw image 不在仓库 |
| `.gitignore` | 恢复为原 `BACKUPS`/`temp`；临时 `archive/` 条目已移除 |

## 4. 备份处理

- Maintainer 最初要求把 raw backup 复制进仓库；曾做本地 ignored copy 并 verify，随后 maintainer 取消该要求并说明会手动 backup。
- 本地 `archive/K4-03_FACTORY_VERIFIED.bin` 已删除；`archive/` 已移除，`.gitignore` 恢复。
- 没有 raw binary 被 tracked/staged/pushed；只提交 manifest、size/hash 和 restore plan。
- 完整 image 含已保存的 Wi-Fi 配置（SSID 在 `0x3FD010` 确认）；必须私有保存。Raw chat log 也不提交。
- Upstream K2-02 `factory_firmware/image4M.bin` 未改，也不是 K4-03 restore image。

## 5. 验证

- **链接/anchor：** tracked Markdown 的 Python checker；**191 个本地链接，0 broken**。
- **容量（LF 源码字符）：** 入口 **7,995**（limit 8,000）；design **3,960**（4,000）；validation **3,996**（4,000）；firmware overview **6,000**（6,000）；display **5,952**（6,000）；hardware **5,989**（6,000）；factory **5,993**（6,000）；time **4,557**；logging **2,951**；configuration **9,558**、build-and-flash **8,754**、deployment **11,055**、fork operations **10,009**。后四个是 detailed contract/runbook/history，不是 navigation index。
- **静态检查：** `git diff --check` 交付前运行；无 code/dependency change。
- **证据边界：** deployment software path 和人工反馈的恢复已记录；详细 display segments、A0/PWM、RTC-only fallback 仍 unverified。Agent 没有访问时钟或私有 backup。
- **产品资格：** 一台 K4-03，不证明 K2-02/K4-03 等价。

## 6. 后续

- 记录详细 display segment/ghosting/秒点 LED 结果。
- 在明暗环境下测 `A0` 和 PWM，再决定是否改 auto brightness；当前用固定亮度。
- 如果时间保持需要正式资格，单独测 RTC-only fallback，与 Wi-Fi 重连分开。
- 测 OTA、Web UI upload、断网 watchdog、power-cycle persistence、长期 Wi-Fi 稳定性。
- 私有 K4-03 backup 放仓库外；restore 前验 size/hash。
- **下一任务：** `VAL-2026-11` — hardware checklist 和 A0 测量；是记录，不是执行授权。
- **交付：** 2026-11-08 随本文档更新 push；准确 commit 用 `git log`。
