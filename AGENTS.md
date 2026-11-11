# ChineseWallClock 项目指令

本文件只保存项目特有的稳定约束。通用的 DSH 文档、会话和 Git 规则见适用的全局 `AGENTS.md` 与技能；不要在这里复制它们的正文。

## 这个仓库是什么

- [`halacs/wallclock`](https://github.com/halacs/wallclock) 的 fork，维护仓库为 `harrywenjie/ChineseWallClock`。
- 针对 **Baiyangshu 1902 Wifi Clock K2 02** 的 Arduino/ESP8266 替换固件。本 fork 的实际机器是两台 **K4-03**（2026-07-23 首台、2026-11-11 第二台；ESP8266EX、26 MHz、4 MB），不要假设它们与 K2-02 的外围电路完全等价。
- 受跟踪的源码仍来自 upstream `d55188e`（2025-07-25）。fork 的提交只有文档，没有改固件源码。
- `releases/`、`factory_firmware/`、`docs/images/`、`docs/display/`、`docs/datasheets/`、`KiCad/` 默认视为 inherited upstream 资产，除非记录明确说明不是。
- fork 的构建记录保存在 `docs/evidence/2026-07-23-fork-build/`；两台 K4-03 的部署记录分别在 `docs/evidence/2026-07-23-k4-03-deployment.md` 和 `docs/evidence/2026-11-11-k4-03-second-unit-deployment.md`。
- 两台 K4-03 的软件路径已通过：build、flash、verify、boot、Web UI；首台还验证 config、Wi-Fi 复用、配置 AP 关闭、断网恢复（人工反馈），第二台手动配置后 maintainer 反馈正常。显示细节和自动亮度根因仍未完全验证；自动亮度偏暗，固定亮度是当前 workaround。不要编造结果。

## 阅读卡

| 任务 | 先读 | 再读 |
|---|---|---|
| 任意一轮 | `README.md`、`docs/DEVELOPMENT.md` §1–2、§5、§7 | 下面的直接合同 |
| 固件行为 | `docs/ENGINEERING_DESIGN.md`、`docs/modules/firmware/README.md` | 对应的专题页 |
| 构建或刷写 | `docs/modules/build-and-flash/README.md` | `docs/evidence/2026-07-23-k4-03-deployment.md`、`docs/evidence/2026-11-11-k4-03-second-unit-deployment.md`、`docs/evidence/2026-11-08-local-build.md` |
| 清理或重建 temp 环境 | `docs/modules/build-and-flash/toolchain-setup.md` | `scripts/README.md`、`libraries/README.md` |
| 部署类似时钟 | `docs/modules/deployment/README.md` | `docs/evidence/2026-07-23-k4-03-hardware-preparation.md`、`docs/evidence/2026-11-11-k4-03-second-unit-deployment.md`、`docs/modules/hardware/README.md`、`docs/modules/factory-firmware/README.md` |
| 硬件或原理图 | `docs/modules/hardware/README.md` | 链接的 datasheet 或 `KiCad/schematic.pdf` |
| 历史或来源 | `docs/history/README.md` | `docs/history/fork-operations.md` |
| 文档维护 | 本文件、`docs/DEVELOPMENT.md` §4 | `docs/maintenance/` 记录 |

不要默认加载所有 module 文档。先读直接依赖；只有修改共享机制、证据冲突或缺少必要约束时，才沿引用补读 history/evidence。

## 硬件与固件约束

- upstream 目标：**ESP-12F**（ESP8266）、4 × **74HC595D** shift register、I2C 上的 **DS3231SM** RTC、`A0` 光敏输入。本 fork 实际机器：两台 **K4-03**、ESP8266EX、26 MHz、4 MB flash。
- Arduino target：`esp8266:esp8266:d1_mini`（Wemos D1 mini / ESP-12F），ESP8266 core **3.1.2**（2026-07-23、2026-11-08 已验证）。实际构建使用 Arduino CLI **0.35.3**、80 MHz、4 MB、`4M2M`、DIO、40 MHz、lwIP v2 Lower Memory、exceptions/debug 关闭。
- shift register 引脚：`SR_OE` GPIO15、`SR_RCLK` GPIO12、`SR_SRCLK` GPIO14、`SR_SER` GPIO13。RTC 使用 ESP8266 默认 `Wire` 引脚（GPIO4/5，除非 schematic 另有说明）。改动接线前对照 `KiCad/schematic.pdf`。
- GPIO15 是 boot strap，74HC595 OE 低有效；复位/启动早期 display 输出可能短暂使能，直到 `displaySetup()` 拉高 OE。这是 K4-03 的首要硬件观察点，不要先把随机段位当成固件 bug。
- 运行时配置是 LittleFS JSON `/halclock.conf`；`Config` 结构和默认值在 `myConfig.h`。Web UI 保存后调用 `wm.reboot()`。
- 网络身份：AP/hostname 为 `halclock` + 大写 chip ID；AP 密码硬编码为 `password`；OTA 密码等于 AP 名。Web UI 没有认证。
- `ENABLE_OTA` 是 `myConfig.h` 中的编译期 define。移除它只排除 OTA，不会增加 Web UI 认证。
- watchdog 在 3 秒 boot delay 后以 8 秒超时启用。不要加入不喂狗的长阻塞逻辑。
- 已验证 build 的 IRAM 已用 **95 %**（62,551 / 65,536 bytes）。加入 IRAM 密集代码前先看 size report。
- 本轮记录的代码级缺陷（未修）：`clever` 不持久化；配置解析/挂载失败不会回退默认值；若干字符串字面量产生 `-Wwrite-strings` warning。见 `docs/modules/firmware/configuration.md` 和 `docs/modules/firmware/README.md`。

## 构建与产物约束

- `libraries/libraries.zip` 是固定库快照。解压到 libraries 目录；没有记录 build 和硬件检查时，不要原地升级、打补丁或“整理”库。
- 从仓库根目录构建，用 `--libraries` 指向解压后的库。build 目录和 toolchain 放在 `temp/`；不要提交。`temp/` 可整体删除，按 [toolchain-setup](docs/modules/build-and-flash/toolchain-setup.md) 用 `scripts/setup-build-env.ps1` 重建。
- 仓库/sketch 目录名保持 `ChineseWallClock`；Arduino 要求目录名与主 `.ino` 一致。build 放短路径；约 209 字符的嵌套路径曾使 GCC 找不到 `bits/cpu_defines.h`（根因未深究）。
- 可复现部署 build：`SOURCE_DATE_EPOCH=1711661163`、Arduino CLI 0.35.3、core 3.1.2；两次 clean build 产出同一 485,280-byte image，SHA-256 `5E4F281421DCE894FED3F03DD9599AF8A690218A85C70B6A5A5DB466748D3D1D`。比较时保留这个 epoch。部署 build 用 `scripts/build-firmware.ps1 -Variant canonical1 -Clean`，脚本会打印 hash 并比较。
- 两台 K4-03 各有完整 **4,194,304-byte** 原厂备份：#1 SHA-256 `59FC45E91B37DCAD5C4E60E90416E3351D303A7CB8739B791CBD999FDC0CA37E`，#2 `5F90B7900C5A60232E7E4CC85EA197451F6B05AAFA89588ECE4A7FD75CE2C01D`。都保存在仓库外的私有目录，含已保存的 Wi-Fi 配置，不只是固件；绝不 commit、push、作为附件上传或交叉使用。原始 image 不复制进仓库，由 maintainer 手动备份。
- `releases/` 和 `factory_firmware/` 是 inherited upstream 资产，不要覆盖。新 release 需要新的日期目录和 maintainer 批准。
- `factory_firmware/image4M.bin` 是 **4,000,000 bytes**（`0x3D0900`），不是完整 4 MiB（`0x400000`）dump，来自 upstream 作者的设备。不要把它当作本 fork 时钟的 per-unit backup。
- 刷写使用 esptool **5.3.1**（或兼容版本），`--before no-reset --after no-reset`，GPIO0 拉低，sketch-only 更新不做 full-chip erase，并做自动 + 独立 verify。记录准确的 image hash/offset。
- 没有自动化测试。compile 不等于 hardware test；分别记录 compiled、flashed、observed on device、deployed。

## 文档规则

- **文档语言为中文**；命令、路径、代码标识符、版本号、状态值（`PASS`/`FAILED`/`UNKNOWN`/`PARTIAL`/`NOT_RUN`/`OPEN`）和英文更准确的术语保留英文。
- `docs/DEVELOPMENT.md` 是唯一当前状态和下一任务入口。`README.md` 是导航加简短项目介绍。不要增加仓库内 TODO、ROADMAP、STATUS、“latest”或 handoff 文件。
- 二进制参考媒体保留原路径：`docs/datasheets/`、`docs/display/`、`docs/images/`、`KiCad/`、`releases/`、`factory_firmware/`。它们是 asset，不是叙述文档。
- 项目操作记录放 `docs/history/fork-operations.md`；原始或复制证据放 `docs/evidence/`；迁移/维护记录放 `docs/maintenance/`。
- 可复用仓库工具放 `scripts/`；文档链接/anchor 和容量检查用 `python scripts/check_docs.py`。`temp/` 里的脚本不是长期副本。
- 项目没有 issue tracker ID。使用日期任务名，如 `DOC-2026-11-08`、`VAL-2026-11`。
- 文档维护绑定：遵循适用全局 `AGENTS.md` §6 和 `doc-governance` skill。默认容量预警：入口 8,000；design/validation 导航 4,000；单个 module/topic 导航 6,000 个 LF 源码字符。不要为了隐藏增长而上调阈值。
- 任何持久变更都在同一轮更新 `docs/DEVELOPMENT.md` 并替换过期结论。不要通过重新整理关闭 `UNKNOWN`/`FAILED`/`NOT_RUN` 或暂停的决定。

## Git 与交付

- 默认分支 `master`；`origin` 是 fork `https://github.com/harrywenjie/ChineseWallClock.git`。没有明确要求，不要 push 到 upstream `halacs/wallclock`。
- commit 前缀：`docs:`、`feat:`、`fix:`、`test:`、`chore:`。
- 不要提交 `temp/`、build 产物、toolchain、凭据、K4-03 私有备份或私有网络标识。仓库已有 upstream 部署截图；不要把其中的 SSID、LAN 地址、MAC、AP chip suffix、私有备份路径写进新文本。整理后的部署记录使用 `<clock-ip>`、`<saved-2.4GHz-network>` 等占位符。
- 本 fork 落后于 upstream（upstream 在 2025-07-25 之后还有提交）。同步或 merge upstream 是单独、明确授权的任务；不要作为文档工作的一部分执行。
