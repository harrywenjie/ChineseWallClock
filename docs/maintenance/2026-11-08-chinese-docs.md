# 2026-11-08 中文文档重写记录

## 1. 范围与边界

- **日期：** 2026-11-08。
- **触发：** maintainer 发现 fork 后新增文档大多为英文，要求用中文重写。英文并非全局规则或 skill 的强制要求，而是上一轮项目 `AGENTS.md` 中按 upstream README 语言做出的项目级选择；本轮改为中文。
- **范围：** `README.md`、`AGENTS.md`、`docs/DEVELOPMENT.md`、`docs/ENGINEERING_DESIGN.md`、`docs/VALIDATION.md`、`docs/modules/**`、`docs/history/**`、`docs/evidence/*.md`、`docs/maintenance/**`。
- **非目标：** 不改代码、依赖、build、flash、hardware、release 或 upstream history；不翻译 raw log、shell 命令、代码标识符、hash、binary 或 inherited `libraries/README.md`。

## 2. 语言与术语规则

- 叙述、标题、表格说明使用中文。
- 命令、路径、代码标识符、版本号、hash、状态值（`PASS`/`FAILED`/`UNKNOWN`/`PARTIAL`/`NOT_RUN`/`OPEN`）保留英文。
- 技术术语按准确性保留英文，例如 ESP8266、ESP-12F、K4-03、K2-02、Arduino CLI、core、FQBN、LittleFS、SDK、OTA、NTP、RTC、DS3231、74HC595、GPIO、PWM、A0、AP、STA、Web UI、build、flash、image、bootloader、esptool、hash、combined image、per-unit backup。
- Raw log、boot log、命令输出、manifest 表头保持原样；不为了“全中文”改写证据。
- `AGENTS.md` 的文档语言规则已从 English 改为中文，并写入上述例外。

## 3. 处理方式

- 保留所有路径、链接和显式 anchor（`release-rebuild`、`hardware-and-deployment`、`known-implementation-notes`、`known-persistence-defects`、`record-template`、`arduino-cli`、`3-phase-1-full-factory-backup`、`provenance`、`current-next`）。
- 标题改为中文；依赖英文 heading slug 的链接改用显式 anchor 或同步检查。
- 把冗长的英文说明压缩为中文，保留事实、状态、数字、命令和证据边界。
- 没有修改 raw evidence 文件（`.log`、`.txt`、`.tsv`、`.sha256`、`.yaml`、脚本、checksum）。
- 没有修改 `libraries/README.md`、`releases/`、`factory_firmware/` 或二进制资产；它们是 inherited upstream/asset。
- 没有修改 K4-03 私有 backup；仓库内仍没有 raw backup binary。

## 4. 验证

- **链接/anchor：** Python checker 覆盖 tracked Markdown；**190 个本地链接，0 broken**。
- **容量（LF 源码字符）：** 入口 **5,330**（limit 8,000）；design **3,083**（4,000）；validation **2,675**（4,000）；firmware overview **4,081**、configuration **5,967**、display **3,840**、time **2,844**、logging **1,734**、hardware **4,041**、build-and-flash **5,977**、factory **4,111**（module 导航 limit 6,000）；history index **2,570**；deployment runbook **7,309** 和 fork operations **6,956** 是 detailed contract/history，不是 navigation index。
- **静态检查：** `git diff --check` 在交付前运行；Markdown code fence、表格列数和行尾空白检查通过。
- **证据边界：** 本轮只改语言和结构，不新增产品/硬件资格；`PASS`/`PARTIAL`/`UNKNOWN` 等状态按原证据保留。
- **隐私：** 扫描确认没有 MAC、SSID、LAN IP、AP chip suffix、私有 backup path 或 chip ID 泄漏到新文本。

## 5. 后续

- 后续新增或修改文档按 `AGENTS.md` 的中文规则执行。
- Raw evidence 仍可保留英文；如果未来需要中文摘要，另加摘要页，不改 raw 文件。
- 若 maintainer 希望 upstream-facing README 保持英文，可在 README 顶部加英文摘要；当前按本轮要求全文中文。
- **交付：** 随本次中文重写提交并 push；准确 commit 用 `git log` 查看。
