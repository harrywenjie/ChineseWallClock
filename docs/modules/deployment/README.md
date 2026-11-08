# 部署 Runbook

这是把固件装到类似 Baiyangshu 时钟上的可复现流程，加上实际 **K4-03** 于 2026-07-23 的部署记录。内容来自 inherited upstream 硬件证据、fork build 记录和 [脱敏部署记录](../../evidence/2026-07-23-k4-03-deployment.md)。

目标是可重复部署，带 per-unit backup 和完整记录。私有标识（MAC、SSID、LAN IP、AP suffix、backup path）不写入仓库；放在私有部署笔记里。

## 1. 预检

- 确认 clock model 和 board marking。upstream 是 **K2-02**；实际 fork 机器是 **K4-03**。两者都用 ESP-12F/ESP8266EX、4 片 74HC595D 和 DS3231，但不要假设电气等价。拍照留档。
- 读 [hardware](../hardware/README.md)、[build and flash](../build-and-flash/README.md)、[factory firmware](../factory-firmware/README.md)。
- 准备 **3.3 V USB-TTL adapter**、dupont 线、未焊 header 时的焊接工具、时钟自身电源，以及装有 `esptool` 和 Arduino toolchain 的电脑。
- 准备 backup 和 log 存储。私有标识（SSID、LAN、MAC、AP suffix、syslog host、backup path）不要进公开仓库。
- 不要一上来就 flash。先做 **read-only backup**，verify，再写。

### 已记录部署（2026-07-23，K4-03）

| 项目 | 实际值 |
|---|---|
| 机器 | BAIYANGSHU **K4-03**、ESP8266EX、26 MHz、4 MB |
| UART | `COM3` 上的 CP210x；只接 GND/TX/RX；时钟自己 USB-A 供电 |
| Boot mode | GPIO0/`FLASH` 接 GND，然后重新上电；无 RST/DTR/RTS |
| Factory backup | 完整 4 MiB，**4,194,304 bytes**，两份，SHA-256 `59FC45E91B37DCAD5C4E60E90416E3351D303A7CB8739B791CBD999FDC0CA37E` |
| Build | Arduino CLI 0.35.3、core 3.1.2、固定 libraries、`SOURCE_DATE_EPOCH=1711661163` |
| Image | `canonical1/ChineseWallClock.ino.bin`，**485,280 bytes**，SHA-256 `5E4F281421DCE894FED3F03DD9599AF8A690218A85C70B6A5A5DB466748D3D1D` |
| Flash | esptool 5.3.1、`0x000000`、`--before/after no-reset`、`--flash-*-keep`、无 full erase |
| 结果 | `Hash of data verified`；独立 `verify-flash` 通过；boot、config、Wi-Fi 复用、AP 关闭、断网恢复通过；自动亮度偏暗，已用固定亮度 |

完整记录（含脱敏 boot log 和确切命令）见 [2026-07-23 K4-03 deployment](../../evidence/2026-07-23-k4-03-deployment.md)。硬件准备和串口排障见 [hardware preparation](../../evidence/2026-07-23-k4-03-hardware-preparation.md)；私有 backup 政策见 [backup manifest](../../evidence/2026-07-23-k4-03-backup-manifest.md)。

<a id="record-template"></a>

## 2. 记录模板

<a id="record-template"></a>

复制到私有部署笔记（如 maintainer 同意，也可写入 `docs/evidence/` 并脱敏私有字段）：

```text
部署日期/时间：
时钟型号 / 板号：
机器标识（私有）：
ESP chip / flash size / MAC（私有）：
Factory backup 文件：
Factory backup 长度（必须是完整 flash）：
Factory backup SHA-256：
Firmware source：commit / release
Firmware image 文件：
Firmware image 形式：full（0x0000）/ app-only（0x1000）
Firmware SHA-256：
Build 工具和版本：
Flash 工具和版本：
Flash offset 和命令：
Serial port / baud：
Boot log 已保存：
Device name：
NTP server：
Timezone（IANA）：
Syslog server（私有）：
Brightness / auto brightness：
Second blinking / clever / leading zeros：
刷后检查（display、time、DST、WiFi、OTA、power cycle）：
问题 / rollback：
```

记录 image **form 和 offset**，不要只写文件名。两个文件可以同名但 offset 不同。

<a id="3-phase-1-full-factory-backup"></a>

## 3. Phase 1 — 完整原厂备份

<a id="3-phase-1-full-factory-backup"></a>

1. 打开时钟，确认 6-pin header。对照 [programming-interface photo](../../images/programming_interface.jpg) 和 schematic 验证 pin order；不要只信标签顺序。
2. 接 3.3 V USB-TTL：`GND`、`TXD0`/`RXD0` 交叉，以及 boot-mode pad。未确认板子电源路径前，不要接 programmer 的 5 V 供电。
3. 进入 ESP8266 bootloader（常见是 `FLASH` low + pulse `RST`；以本板为准）。
4. 先检测 chip 和 flash size：

   ```text
   esptool --port <PORT> flash_id
   ```

5. 读**完整** flash，不要只读 upstream 的 4,000,000-byte 前缀：

   ```text
   esptool --port <PORT> --baud 115200 read_flash 0x000000 0x400000 factory-full-4MiB.bin
   ```

   `0x400000` = 4,194,304 bytes。只有 `flash_id` 报告不同 size 时才改，并记录实际值。
6. 校验长度和 hash：

   ```text
   Get-FileHash factory-full-4MiB.bin -Algorithm SHA256
   ```

   Linux/macOS 用 `sha256sum`。backup 和 hash 离线保存；只在 bench 机器上不算 backup。
7. 长度、chip、flash size、hash 都记录前，不要继续。

实际 K4-03 的两次完整读取都得到 **4,194,304 bytes**，SHA-256 `59FC45E91B37DCAD5C4E60E90416E3351D303A7CB8739B791CBD999FDC0CA37E`。该 backup 含已保存的 Wi-Fi 配置，不是纯固件；必须私有保存。

inherited `factory_firmware/image4M.bin` **不是**这一步的替代品：它只有 4,000,000 bytes，来自 upstream K2-02 作者，4 MiB 的最后 194,304 bytes 没读到。见 [factory firmware](../factory-firmware/README.md)。

## 4. Phase 2 — 构建或选择 image

- 优先用当前源码和固定 toolchain/libraries 构建。按 [build and flash](../build-and-flash/README.md#arduino-cli) 操作；toolchain 缺失时先按 [toolchain setup](../build-and-flash/toolchain-setup.md) 重建。
- 用 inherited release 时，对照 [validation](../../VALIDATION.md#release-rebuild) 验 size/hash。v1.1 是 full image，不是 app-only。
- 记录 source commit 和 image SHA-256。不要只写“latest build”。
- 选 image form：full `0x0000`，或 bootloader 已知完好时 app-only `0x1000`。不确定就用 full。

## 5. Phase 3 — 刷写

只是模板；执行前核对工具选项和板子的 flash mode/frequency/size：

```text
esptool --port <PORT> --baud 115200 write_flash \
  --flash_mode dio --flash_freq 40m --flash_size 4MB \
  0x0000 <full-image.bin>
```

app-only 改 offset `0x1000` 和文件；永远不要把 full-image 的 offset 用在 app-only 上。115200 捕获完整 esptool 输出和 serial boot log。

实际 K4-03 写入使用 `--flash-mode keep --flash-freq keep --flash-size keep`、`0x000000`、485,280-byte combined image，没有 full-chip erase。esptool 只擦 `0x000000–0x076FFF`，写 485,280 bytes，报 `Hash of data verified`；独立 `verify-flash` 报 `Verification successful (digest matched)`。

进不了 bootloader 时，停下来检查接线/供电，不要换 offset 盲试。

## 6. Phase 4 — 首次 boot 和配置

1. 正常给时钟供电，打开 **115200** serial。应看到 `[INFO] Booting`、配置、AP name/password、NTP 结果、WiFi 结果和 reset reason。
2. 首次 boot 连 AP `halclock<chipid>`，password `password`（已有配置时用实际值）。
3. 打开 portal，填：
   - device name（如 `Kitchen clock`，会成为页面标题）；
   - NTP server（可达的 server；默认 `hu.pool.ntp.org`）；
   - timezone，精确 IANA 名（如 `Europe/Budapest`）；
   - syslog server（可选，私有 LAN collector）；
   - brightness 和四个 checkbox；
   - WiFi SSID/password。
4. Save。固件写 `/halclock.conf` 并 reboot。重新连 station network；portal 应该还能在 device IP 访问。
5. 把有效配置和 device IP 记到私有部署笔记。不要公开 SSID、LAN、MAC 或 syslog host。

实际 K4-03 保留了原厂 SDK 区 Wi-Fi 配置，所以直接连上原网络；配置 AP 关闭。后来把 timezone 改成 `Pacific/Auckland`、NTP 改成 `nz.pool.ntp.org`、syslog 留空；自动亮度偏暗后改用固定 manual brightness。

## 7. Phase 5 — 验证

- **Display：** 所有 segment、`HH:MM`、无 ghosting；leading-zero/clever 设置；秒点 LED 常亮/闪烁；brightness 1/128/255；auto brightness。实际 K4-03 自动亮度偏暗，固定亮度是已知 workaround。
- **Time：** serial 显示 NTP 成功；local time 和 DST 正确；阻断 NTP 重启，验证 DS3231 fallback；装 RTC 电池 power-cycle。
- **Network：** AP name/password、portal title、station 连接、网页可达、hostname/IP。
- **OTA：** Arduino IDE network port 出现；password 是 AP 名；测试 upload 成功（不要用 broken 的 Web UI upload）。
- **Persistence：** 每个字段 save、reboot、确认保留；重点测 `clever`（已知缺陷）和 leading zeros。
- **Recovery：** 在 spare unit 上损坏 `/halclock.conf`，记录结果；当前代码可能不回退默认值。
- **Power：** 拔插电源；确认不接 serial 也能恢复。

## 8. Phase 6 — 收尾

1. 填记录模板。
2. 把完整 factory backup、firmware image、log、hash 放在一起。
3. 更新 `docs/DEVELOPMENT.md` §1/§5，并加带日期的 evidence 页（私有字段脱敏）。
4. 明确区分 device 上观察到的和只 compile 的。
5. 新部署稳定运行一段时间前，保留上一个可用 image 和 backup。

## 9. 回滚

1. 断电，进 bootloader，把 **per-unit** 完整 backup 写回 `0x000000`，flash mode/frequency/size 与 backup 时一致。
2. 实际 K4-03 先复核私有 backup SHA-256 `59FC45E91B37DCAD5C4E60E90416E3351D303A7CB8739B791CBD999FDC0CA37E` 和 4,194,304 bytes。
3. 校验写入并 boot；保存 serial log。
4. 不要把 inherited upstream 4,000,000-byte dump 恢复到另一台机器；它不完整且是 K2-02-specific。

## 10. 已知风险

- Web UI firmware upload 报告 broken；serial 和 OTA 是已知路径。
- AP password 硬编码 `password`，OTA password 是 AP 名，Web UI 无认证。
- IRAM 已 95 %；代码增长可能 build 失败或行为变化。
- K4-03 风险：GPIO15 是低 boot strap，active-low OE 可能在 reset 时短暂使能 display；display mapping 硬编码；本机 auto brightness 偏暗（测量 A0/PWM 前用固定亮度）；DS3231 detection 未 log；蓝灯不受控。
- K4-03 factory backup 含已保存的 Wi-Fi 配置。不要 commit、upload 或分享；只能从 per-unit backup 恢复。
- upstream 截图只证明 upstream 固件的一次部署，不是本 fork 机器或配置的证据。本 fork 的实际记录是 [K4-03 deployment](../../evidence/2026-07-23-k4-03-deployment.md)。
