# 验证与证据

本页记录已经证明了什么、依据是什么、还有什么未验证。它不产生产品资格。

## 1. 资格规则

compile 只证明源码能用指定 toolchain/libraries 构建；hash 只证明文件存在；deployment 还需要设备、backup、image/offset、配置和刷后检查。不要把这些等级合并成一个“全部通过”。

## 2. 状态

| 声称 | 状态 | 证据/原因 |
|---|---|---|
| 固件在 `d55188e` 可 compile | **PASS** — 2026-11-08 | [local build](evidence/2026-11-08-local-build.md) |
| K4-03 flash + verification | **PASS** — 2026-07-23 | [deployment record](evidence/2026-07-23-k4-03-deployment.md) |
| K4-03 boot、config、Wi-Fi/AP | **PASS** — 2026-07-23 | 同一记录；AP 已关闭，Wi-Fi 已复用 |
| K4-03 断网恢复 | **PASS** — 人工反馈 | 能自动恢复；RTC/Wi-Fi 路径未分离 |
| K4-03 display 细节兼容性 | **PARTIAL** | 初次目视正常；segment mapping 未记录 |
| K4-03 自动亮度 | **FAILED / USABILITY** | 偏暗；已改用固定 manual brightness |
| v1.1 精确重建 | **UNKNOWN** | 485,280 vs 485,248 bytes；原因未定位 |

## 3. 构建

**2026-07-23 deterministic build：** Arduino CLI 0.35.3、core 3.1.2、bundled libraries；`SOURCE_DATE_EPOCH=1711661163`；两次 clean build byte-identical；image **485,280 bytes**，SHA-256 `5E4F281421DCE894FED3F03DD9599AF8A690218A85C70B6A5A5DB466748D3D1D`。

**2026-11-08 local compile：** 同源码/toolchain/libraries，但未固定 epoch；exit 0；485,280 bytes，SHA-256 `4898…50C6`；14 个 warning，0 error。完整记录：[2026-11-08 build](evidence/2026-11-08-local-build.md)。

## 4. 实际 K4-03 部署

实际 K4-03 于 **2026-07-23** 刷写（maintainer 确认）。完整 4 MiB backup 读取两次，SHA-256 `59FC…E37E` 一致；firmware `5E4F…D3D1D` 写入 `0x000000`，esptool 5.3.1，未 full erase，自动和独立 verification 均通过。首次启动、配置保存/读回、Wi-Fi 复用、AP 关闭和断网恢复通过；自动亮度偏暗，已改固定 manual brightness。这证明 software/deployment 路径，不等于完整 hardware compatibility。详情：[deployment record](evidence/2026-07-23-k4-03-deployment.md)。

<a id="release-rebuild"></a>

## 5. Release 重建

v1.1 为 485,248 bytes，SHA-256 `1FB0…29FC`；2026-07-23 canonical build 为 485,280 bytes，SHA-256 `5E4F…D3D1D`。源码与 v1.1 code-identical（`git diff 7d18e68..HEAD` 未改代码），但 image 大 32 bytes。v1.1 精确重建为 **UNKNOWN**；当前源码在固定 epoch、相同 build path/toolchain 下可复现。

<a id="hardware-and-deployment"></a>

## 6. 硬件与剩余测试

未记录：详细 segment mapping/ghosting、latch timing/flicker、DS3231-only fallback、A0/PWM 测量、OTA、断网 watchdog、power-cycle persistence、长期漂移、K2-02 与 K4-03 的电气差异。断网恢复为人工反馈，RTC/Wi-Fi 路径未分离。

K4-03 风险：GPIO15 是低有效 boot strap，active-low 74HC595 OE 可能在 reset 时短暂使能输出；display mapping 硬编码；本机自动亮度偏暗（在测量前用固定亮度）；蓝灯不受固件控制。Web UI firmware upload 仍未验证。

## 7. 扩展与保全证据

1. 在已部署机器上跑 [deployment runbook](modules/deployment/README.md) 的 hardware checklist，保留 serial log 和观察结果。
2. 重刷前复核私有 K4-03 backup hash 和 firmware hash/offset；不要用 upstream K2-02 factory image 恢复 K4-03。
3. 新增带日期的 evidence 页，并更新 `docs/DEVELOPMENT.md` §1/§5；不要改写历史观察来制造成功。
4. 私有标识（SSID、LAN、MAC、AP suffix、backup path）必须脱敏；私有 backup 不得进入 Git。`UNKNOWN`、`FAILED`、`NOT_RUN` 在新证据或明确决定前保持原状态。
