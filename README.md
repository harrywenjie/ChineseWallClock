<a href="https://www.buymeacoffee.com/halacs" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>

**ABSOLUTELY NO WARRANTY! USE AT YOUR OWN RISK!**

# Chinese Wall Clock

面向 **Baiyangshu 1902 Wifi Clock K2 02**（“Chinese Wall Clock”）的开源替换固件。它用 ESP8266/Arduino 固件替换原厂固件，提供 Web UI、NTP + DS3231 时间保持、支持 DST 的时区、自动亮度、Arduino OTA 和 syslog。

本仓库是 [`halacs/wallclock`](https://github.com/halacs/wallclock) 的 fork，维护在 [`harrywenjie/ChineseWallClock`](https://github.com/harrywenjie/ChineseWallClock)。upstream 目标是 K2-02；本 fork 的实际机器是 **BAIYANGSHU K4-03**。受跟踪的源码来自 upstream；fork 的本地操作和实际部署单独记录。

![设备](docs/images/device_picture.png)

## 从这里开始

- **[开发入口](docs/DEVELOPMENT.md)** — 当前状态、未决项和下一任务。先读这个。
- **[硬件](docs/modules/hardware/README.md)** — 主板、元件、引脚、编程接口、schematic 和 datasheet。
- **[固件行为](docs/modules/firmware/README.md)** — boot 流程、配置、显示、时间、日志和已知实现问题。
- **[构建与刷写](docs/modules/build-and-flash/README.md)** — toolchain、固定库、image 形式、offset、OTA 和常见故障；[从零重建 toolchain](docs/modules/build-and-flash/toolchain-setup.md)。
- **[部署 runbook](docs/modules/deployment/README.md)** — 类似时钟的端到端流程，包括 factory backup 和 record template。
- **[原厂固件](docs/modules/factory-firmware/README.md)** — upstream 的 4,000,000-byte dump、提取命令和原厂 UI。
- **[历史与来源](docs/history/README.md)** — upstream baseline、fork 本地操作和保留的 2026 构建证据。
- **[验证](docs/VALIDATION.md)** — 已证明什么、未证明什么，以及证据边界。
- **[实际 K4-03 部署](docs/evidence/2026-07-23-k4-03-deployment.md)** — 首台真实刷写、校验、首次启动和配置记录（私有标识已脱敏）。
- **[第二台 K4-03 部署](docs/evidence/2026-11-11-k4-03-second-unit-deployment.md)** — 2026-11-11 per-unit backup、flash、verify、boot/Web UI（私有标识已脱敏）。
- **[K4-03 硬件准备](docs/evidence/2026-07-23-k4-03-hardware-preparation.md)** — 焊接、串口/GND 排查、针脚确认和下载模式。
- **[K4-03 备份清单](docs/evidence/2026-07-23-k4-03-backup-manifest.md)** — 私有 full-flash backup 和恢复预案（原始 image 不在仓库内）。

## Release 与硬件文件

- [Release binaries](releases/) — inherited v1.0（2024-03-23）和 v1.1（2024-04-01）。
- [Upstream K2-02 原厂固件 dump](factory_firmware/image4M.bin) — 不是 K4-03 的恢复镜像；恢复前先看 [原厂固件说明](docs/modules/factory-firmware/README.md)。
- [KiCad schematic](KiCad/schematic.pdf)。
- [固定 Arduino 库](libraries/libraries.zip) — 作者的备份；见 [libraries/README.md](libraries/README.md)。

## 项目链接

- [作者博客](https://www.halacs.hu/baiyangshu-1902-wifi-clock-k2-02)
- [Upstream 仓库](https://github.com/halacs/wallclock)

## 贡献

向本 fork 提交 pull request。说明改了什么、如何测试。compile 不等于 hardware test；分别说明哪些在真实时钟上运行过。修改固件或文档前先读 [开发入口](docs/DEVELOPMENT.md) 和 [项目指令](AGENTS.md)。
