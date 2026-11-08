# Fork 操作记录

本页记录 fork 在 clone 之后实际做了什么。Tracked source 没有 fork 改动；fork 提交只有文档。Fork 本地证据包括被忽略的 `temp/` build 记录和用户提供的 Codex 部署记录，整理后放 `docs/evidence/`。

时间是 workspace local time（2026 年 7 月为 UTC+12），根据 clone reflog、文件 mtime 和聊天片段重建。不是正式 session log；部署日期由 maintainer 确认为 **2026-07-23**。

## 1. 时间线

| 时间 | 操作 | 证据 |
|---|---|---|
| 2026-01-27 20:03 UTC | 从 `halacs/wallclock` fork 出 `harrywenjie/ChineseWallClock` | GitHub API |
| 2026-07-23（时间未记录） | 焊接/串口/GND 排障；两次完整读取 factory flash；backup 校验 | [hardware preparation](../evidence/2026-07-23-k4-03-hardware-preparation.md) |
| 2026-07-23 14:08:33 +12 | 从 fork remote 本地 clone，HEAD `d55188e` | `.git` reflog、`git status` |
| 2026-07-23 ~14:22–14:26 | 下载 Arduino CLI 0.35.3/1.5.1、Arduino IDE 2.3.2 source；建 local CLI config；安装 ESP8266 core 3.1.2；解压 bundled libraries；建 PDF venv 并渲染 schematic | `temp/downloads/`、`temp/toolchain/`、`temp/arduino-cli.yaml`、`temp/arduino-data/`、`temp/bundled/`、`temp/pdf-venv/`、`temp/pdfs/` |
| 2026-07-23 14:27 | `default` build | `temp/logs/build-default.log`、`temp/artifacts/default/` |
| 2026-07-23 14:29 | `repro2` build | `temp/artifacts/repro2/` |
| 2026-07-23 14:31–14:32 | Arduino IDE 2.3.2 source/CLI-options build；提取 `0x1000` app-only image | `temp/build/ide232-cli/`、`temp/artifacts/ide232-cli/`、`temp/artifacts/default/app.bin` |
| 2026-07-23 14:34 | `canonical1`、`canonical2` deterministic build | `temp/build/canonical1/`、`temp/build/canonical2/`、`temp/logs/build-canonical-ide232-cli.log` |
| 2026-07-23 ~14:34–14:52 | 刷前 hash 检查和批准；`0x000000` flash；自动 + 独立 verify；首次 boot；改配置；第二次 boot（chat 只显示 14:52，精确时间未记录） | [K4-03 deployment](../evidence/2026-07-23-k4-03-deployment.md) |
| 2026-11-08 | 文档迁移、部署记录和本地 compile 验证 | `docs/`、`docs/evidence/` |

## 2. Fork 本地变更与 setup

Tracked firmware source 没有 fork 改动：build 时复制的 `.cpp` 在去掉生成的 `#line` 后与 upstream 一致，tracked source 仍是 `d55188e`。fork 本地工作是文档，加 `temp/` build 环境和实际部署。

- **实际机器：** BAIYANGSHU **K4-03**，不是 upstream K2-02。ESP8266EX、26 MHz、4 MB。K2-02 schematic 只作接线参考，电气等价性未证明。物理准备和 pin 确认见 [hardware preparation](../evidence/2026-07-23-k4-03-hardware-preparation.md)。
- **Factory backup：** 完整 4 MiB 读取两次；两份 4,194,304-byte 文件 SHA-256 均为 `59FC45E91B37DCAD5C4E60E90416E3351D303A7CB8739B791CBD999FDC0CA37E`。Backup 私有，含已保存的 Wi-Fi 配置（不只是固件），绝不进入 Git。[Backup manifest](../evidence/2026-07-23-k4-03-backup-manifest.md)。
- **Arduino CLI：** 使用 0.35.3；1.5.1 也下载了。Windows 64-bit archive 在 `temp/downloads/`。
- **Arduino IDE：** 下载 2.3.2 source archive（`arduino-ide-2.3.2-source.zip`，3,326,414 bytes），用于核对/复现 IDE build options。
- **ESP8266 core：** `esp8266:esp8266` **3.1.2**，安装在 `temp/arduino-data/packages/esp8266/hardware/esp8266/3.1.2`。
- **Libraries：** `libraries/libraries.zip` 解压到 `temp/bundled/libraries`。逐文件对比：**0 modified**，1 个额外 example；等于固定快照。
- **Board manager URL：** `https://arduino.esp8266.com/stable/package_esp8266com_index.json`。
- **CLI config：** `temp/arduino-cli.yaml` 把 data/downloads/user 指到 `temp/`。
- **Schematic：** PyMuPDF 1.26.3 + pypdf 6.1.1 把 `KiCad/schematic.pdf` 渲染成 300 dpi 页面和 600 dpi detail crops，输出在 `temp/pdfs/`。Schematic 确认 K2-02 pin map 和 GPIO15/OE early-enable 风险。
- **Flash 工具：** esptool **5.3.1**，`COM3` 上的 CP210x，未接 RST/DTR/RTS；manual GPIO0 boot mode 和 `--before/after no-reset`。

## 3. Build 结果

所有 variant 用同一 upstream 源码、core 和 library 版本。产生五个 build 目录；所有完整 image 都是 **485,280 bytes**。

| Variant | Build 目录 | Custom build property | Full image | 说明 |
|---|---|---|---|---|
| default | `temp/build/default` | none | 485,280 B | 直接 Arduino CLI build |
| repro2 | `temp/build/repro2` | none | 485,280 B | repeat build |
| ide232-cli | `temp/build/ide232-cli` | `build.warn_data_percentage=75` | 485,280 B | IDE-2.3.2-like options |
| canonical1 | `temp/build/canonical1` | `build.warn_data_percentage=75` | 485,280 B | 最终 deterministic build |
| canonical2 | `temp/build/canonical2` | `build.warn_data_percentage=75` | 485,280 B | 不同 build path 的 repeat |

最终 deterministic build 固定 `SOURCE_DATE_EPOCH=1711661163`（最后固件源码 commit 时间，2024-03-28T22:26:03+01:00），使用 Arduino CLI 0.35.3。两次 independent clean build 产出 byte-identical image：**485,280 bytes**，SHA-256 `5E4F281421DCE894FED3F03DD9599AF8A690218A85C70B6A5A5DB466748D3D1D`。这是实际刷入的 image。

Size report 对所有 logged variant 相同：RAM 37,404 / 80,192（46 %），IRAM 62,551 / 65,536（95 %），flash 443,980 / 1,048,576（42 %）。Build log 有 14 个 `-Wwrite-strings` warning，0 error。

`temp/artifacts/default/app.bin`（481,184 bytes）是完整 image 去掉前 4,096 bytes；开头是 app-image header `e9 05 02 40`，对应 `0x1000` app 区。它是派生 image，不是独立 firmware。刷入的是 combined `canonical1/ChineseWallClock.ino.bin`：eboot 在 `0x000000`，application 在 `0x001000`，没有独立 filesystem image。

没有 variant 匹配 v1.1 release 大小（485,248 bytes）。32-byte 差异在 `docs/VALIDATION.md` 记为 **UNKNOWN**，未解决。

## 4. 部署记录

详细记录见 [2026-07-23 K4-03 deployment](../evidence/2026-07-23-k4-03-deployment.md)。摘要：

- 刷前重新校验私有 factory backup hash 和 firmware hash，确认 bootloader 连接，没有 full-chip erase。
- 用 esptool 5.3.1 在 `0x000000` 写入，`--before no-reset --after no-reset`、`--flash-mode keep --flash-freq keep --flash-size keep`、115200 baud。
- esptool 报 `Hash of data verified`；独立 `verify-flash` 报 `Verification successful (digest matched)`。
- 首次 boot：LittleFS mount，没有 config file，加载 default；保留的 SDK Wi-Fi 配置重新连上网络；Web UI 可达。
- Portal 保存 `Pacific/Auckland`、`nz.pool.ntp.org`、空 syslog 和 display options；第二次 boot 读回配置并使用 `REASON_SOFT_RESTART`。
- 只写 `0x000000–0x076FFF`，SDK Wi-Fi 参数区保留。
- 人工反馈：Wi-Fi 复用、配置 AP 关闭、断网后能自动恢复。自动亮度偏暗；maintainer 改用固定 manual brightness。

这是 **software/deployment pass**，不是完整 hardware compatibility。Display 细节和 auto-brightness 根因仍 partial。

## 5. 仍缺什么

- 详细 display segment/ghosting、秒点 LED 结果。Maintainer 说设备看起来正常，但没有详细测试记录。
- Auto-brightness 根因和 A0/PWM 测量。断网恢复是人工报告，RTC-only 路径未分离。
- 原始 Codex chat log 未提交；公开来源是整理后的记录。私有值（MAC、SSID、LAN IP、AP suffix、backup path）刻意省略。
- OTA upload、Web UI firmware upload、断网 watchdog、power-cycle persistence、corrupt-config recovery、长期 Wi-Fi 稳定性未验证。
- K2-02 与 K4-03 电气差异没有文档化；只有 K2-02 schematic 和实际 K4-03 boot 行为。

## 6. 与 upstream 的关系

Fork tracked source 是 upstream `d55188e`；文档提交不改 firmware。upstream 有 2026-09-05 push 的新 commit，未 merge。2024 release、factory dump、截图是 upstream 资产，不是 fork 操作。实际机器是 K4-03，所以 upstream K2-02 factory image 不是它的恢复镜像。不要把 2026-07-23 K4-03 部署说成 upstream release，也不要把 upstream 截图当作本机证据。

## 7. 保留证据

- [2026-07-23 K4-03 deployment](../evidence/2026-07-23-k4-03-deployment.md) — build、backup、flash、verify、boot log、config。
- [2026-07-23 hardware preparation](../evidence/2026-07-23-k4-03-hardware-preparation.md) — 焊接、串口/GND、pin 确认、auto-brightness 发现。
- [2026-07-23 backup manifest](../evidence/2026-07-23-k4-03-backup-manifest.md) — 私有 full-flash backup 和 restore plan（原始 image 不在仓库）。
- [2026-07-23 fork build](../evidence/2026-07-23-fork-build/README.md) — tool 版本、build variant、log、config/script、artifact hash。
- [2026-11-08 local build](../evidence/2026-11-08-local-build.md) — 当前 compile 验证。
- [Validation](../VALIDATION.md) — 这些证据证明了什么、没证明什么。
