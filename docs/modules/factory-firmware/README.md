# 原厂固件与原厂 UI

本页记录 inherited upstream factory-firmware backup、实际 K4-03 per-unit backup、upstream image 的提取方式，以及原厂固件 UI。upstream image **不是** K4-03 恢复镜像。

## 1. 备份文件

`factory_firmware/image4M.bin` 是原厂时钟的 flash dump：

| 属性 | 值 |
|---|---|
| 大小 | **4,000,000 bytes**（`0x3D0900`） |
| SHA-256 | `577F86DE790229E70824DB782B48BF33701905760CB49BEA1E94FB0CABED0447` |
| 来源 | upstream 作者的设备，2024-03-23 文档 commit 加入 |
| 形式 | partial full-flash dump，不是 Arduino app image |

完整 4 MiB flash 是 `0x400000` = 4,194,304 bytes；这个文件少 194,304 bytes。不要恢复到另一台时钟。

### 实际 K4-03 per-unit 备份（本 fork）

实际机器是 **K4-03**，不是 upstream K2-02。刷写前原厂 flash 被读取两次：

| 属性 | 值 |
|---|---|
| 大小（每个） | **4,194,304 bytes**（`0x400000`） |
| SHA-256（两份） | `59FC45E91B37DCAD5C4E60E90416E3351D303A7CB8739B791CBD999FDC0CA37E` |
| 文件 | 历史 `_1`/`_2`；当前 `K4-03_FACTORY_VERIFIED.bin`（私有） |
| 校验 | 两次读取一致，记录为 `BACKUP VERIFIED` |

它包含已保存的 ESP8266 SDK Wi-Fi 配置（SSID 已在 SDK 区确认）。绝不能 commit、复制进 `temp/`、作为 issue 附件或公开分享。只能从这个 per-unit backup 恢复，不能用 `factory_firmware/image4M.bin`。见 [backup manifest](../../evidence/2026-07-23-k4-03-backup-manifest.md)。

恢复命令（完整 4 MB 写到 `0x000000`）：

```powershell
py -m esptool --chip esp8266 --port COM3 --baud 115200 `
  --before no-reset --after no-reset `
  write-flash 0x000000 `
  <private-backup-dir>\K4-03_FACTORY_VERIFIED.bin
```

没有重新校验 hash 和明确批准，不要执行。见 [deployment record](../../evidence/2026-07-23-k4-03-deployment.md)。

## 2. 它是怎么提取的

upstream 截图 `docs/images/factory_firmware/download_factory_firmware.png` 记录命令（原始文件名 `Screenshot from 2024-03-14 22-12-57.png`）：

```text
esptool --port /dev/ttyUSB0 read_flash 0x00000 0x3D0900 image4M.bin
```

截图显示 `esptool.py v4.7.0` 从 ESP8266EX（26 MHz）读 4,000,000 bytes，耗时 360.4 秒。命令读 `0x3D0900`，不是 `0x400000`；这就是长度不完整的来源。正确的 per-unit backup 应按 `esptool flash_id` 报告的大小读取（4 MiB 通常是 `0x400000`）。

![Factory firmware 提取](../../images/factory_firmware/download_factory_firmware.png)

## 3. 熵分析

Dump 的 entropy 图（`docs/images/factory_firmware/binwalk_entropy.png`）：

- 前 0–0.5 MB 左右高 entropy（firmware/application 区）。
- 1.0 MB 附近有一段窄的高 entropy（可能是 filesystem）。
- 其余大部分接近 0（erased flash）。

这是 dump 有真实内容的 sanity check，不是安全分析或恢复流程。

![Entropy 分析](../../images/factory_firmware/binwalk_entropy.png)

## 4. 原厂固件 UI

Inherited 截图展示原厂 Web UI：

| 页面 | 图 | 记录内容 |
|---|---|---|
| Main menu | [main.png](../../images/factory_firmware/main.png) | 六个 setup 入口，“BRIGHTEN UP YOUR TIME!” |
| Clock base | [base.png](../../images/factory_firmware/base.png) | first-zero、second-dot flash、24 h、clever `1`、temperature revision |
| Light PWM | [brightness.png](../../images/factory_firmware/brightness.png) | LED level、auto-light off |
| Auto power | [auto_on-off.png](../../images/factory_firmware/auto_on-off.png) | auto power off；示例 7:00–22:00 |
| NTP | [ntp.png](../../images/factory_firmware/ntp.png) | LAN NTP、固定 `UTC +01:00 CET`、DST off |
| WiFi | [wifi.png](../../images/factory_firmware/wifi.png) | SSID/password、scan/list |
| Load defaults | [load_factory_defaults.png](../../images/factory_firmware/load_factory_defaults.png) | restore all / retain WiFi / set from mobile |

这些 upstream 图里的网络标识、地址和 MAC 不转写。

## 5. 为什么替换

upstream README 的理由：

- 原厂固件常驻 WiFi AP。
- 没有自动 DST（NTP 页是固定 UTC+1、DST off）。
- 替换固件开源、可扩展。

替换固件增加 Web UI、NTP + DS3231 时间保持、timezone/DST、可选秒点 LED、leading-zero/clever 显示、manual/auto brightness、Arduino OTA 和 syslog。当前功能和缺口见 [firmware](../firmware/README.md) 和 `docs/DEVELOPMENT.md` §5。

## 6. 恢复注意事项

- upstream dump 是 **partial full-flash**：写到 `0x000000` 只恢复 4,000,000 bytes，tail 不动。tail 已 erased 时可能够用，但不是 verified full restore。
- upstream dump 来自 K2-02 作者设备。恢复到 K4-03 可能带错 MAC/calibration/configuration，不是 per-unit recovery。
- K4-03 backup 完整（4,194,304 bytes），是本机唯一有效的 per-unit restore。hash 在 §1；它含已保存的 Wi-Fi 配置。
- factory image 不是 Arduino app-only image。不要写到 `0x1000`。
- 恢复前先复核私有 backup hash 和 size。不要先 erase chip；full-image write 会覆盖 flash。
- 本 workspace 没验证恢复；在设备测试记录前保持 **NOT_RUN**。

## 7. 来源

Inherited upstream 资产加 K4-03 backup；没有 fork factory-firmware 修改。2024-03-14 截图是 upstream 提取，不是 fork 部署。实际 K4-03 部署见 [deployment](../../evidence/2026-07-23-k4-03-deployment.md)。
