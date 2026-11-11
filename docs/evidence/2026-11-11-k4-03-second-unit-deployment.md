# 2026-11-11 第二台 K4-03 部署记录

本页记录第二台 **BAIYANGSHU WiFi Clock K4-03** 的 factory backup、flash、verify、boot 和 Web UI 结果。它与 [2026-07-23 首台 K4-03](2026-07-23-k4-03-deployment.md) 是不同物理单元；backup、hash 和恢复 image 不能交叉使用。

## 1. 来源与隐私

- **来源：** 2026-11-11 maintainer 现场操作，通过 `COM3` 上的 CP210x、esptool 和串口捕获；不是原始 chat log。
- **设备：** maintainer 确认同型号 K4-03；ESP8266EX、26 MHz、4 MB；flash ID Manufacturer 20 / Device 4016。
- **脱敏：** 公开记录去掉 MAC、SSID、LAN 地址、AP chip suffix 和私有 backup path。完整 4 MiB backup 含已保存 Wi-Fi 配置，只保存在仓库外私有目录；不提交、不上传。
- **边界：** 本页记录一次实际刷写，不把第二台结果扩展为所有 K4-03 revision 的兼容性证明。

## 2. 刷前只读检查

- 原厂固件运行时，`COM3` 115200 周期输出 `DS3231:2026.11.11...` 和 `showview time`；日期/时间与本地一致，证明 clock TX → CP210x RX，原厂应用和 DS3231 在运行。没有 boot banner 是因为时钟已经启动。
- 按 K4-03 header 记录，将 **pin 1 FLASH/GPIO0** 短接到 **pin 3 GND**，重新上电进入 bootloader；未接 RST/DTR/RTS。
- `esptool chip-id`：ESP8266EX、26 MHz；`flash-id`：4 MB（Manufacturer 20、Device 4016）。MAC 不记录。
- 未短接时 `esptool chip-id` 失败是预期；没有写入。

## 3. 原厂 backup

| 项目 | 值 |
|---|---|
| 范围 | `0x000000–0x400000`（完整 4 MiB） |
| 读取次数 | 两次 independent full read |
| 每份大小 | **4,194,304 bytes** |
| SHA-256（两份一致） | `5F90B7900C5A60232E7E4CC85EA197451F6B05AAFA89588ECE4A7FD75CE2C01D` |
| 耗时 | 每份 382.1 s，115200 baud，约 87.8 kbit/s |
| 私有文件 | `K4-03-new_factory_1.bin`、`_2.bin`、`K4-03-new_FACTORY_VERIFIED.bin`（仓库外） |
| Restore | **NOT_RUN**；restore 命令只是预案 |

- 首字节 `e9 03 02 40`，与 ESP8266 bootloader image 一致。
- 与首台 backup SHA-256 `59FC…E37E` 不同；这是 per-unit backup，**不能**用首台 image 恢复第二台。
- 原始 image 不复制进仓库；仓库只记录 size/hash 和边界。

## 4. Build 与 image

- 使用同一 deterministic image：`canonical1/ChineseWallClock.ino.bin`，**485,280 bytes**，SHA-256 `5E4F281421DCE894FED3F03DD9599AF8A690218A85C70B6A5A5DB466748D3D1D`。
- 源码 `d55188e`；Arduino CLI 0.35.3、core 3.1.2、固定 libraries、`SOURCE_DATE_EPOCH=1711661163`。详见 [2026-07-23 fork build](2026-07-23-fork-build/README.md) 和 [2026-11-08 local build](2026-11-08-local-build.md)。
- 刷入前复核 image size/hash；没有改 firmware source。

## 5. Flash

- **实际供电：** CP210x 5V 单电源，时钟自身 USB-A 未接。首台记录使用时钟自身 USB-A；maintainer 说明首台当时有虚焊，本次 CP210x 供电在两次完整读取和写入期间稳定。这是**本次 unit/session 的实际条件**，不替代部署 runbook 的供电建议。
- 命令（脱敏，`<image>` 指上面的 image）：

```powershell
python -m esptool --chip esp8266 --port COM3 --baud 115200 `
  --before no-reset --after no-reset `
  write-flash `
  --flash-mode keep --flash-freq keep --flash-size keep `
  0x000000 <image>
```

- 结果：写入 **485,280 bytes** 到 `0x000000`，29.7 s，compressed 331,936 bytes，约 130.7 kbit/s；没有执行 full-chip erase。
- esptool 自动校验：`Hash of data verified`。
- 独立 `verify-flash 0x000000 <image>`：`Verification successful (digest matched)`。
- 写入后设备仍在 bootloader；没有自动 reset（RST 未接）。

## 6. Boot 与网络

- 断电、移除 FLASH 短接、重新上电。由于 CP210x 单电源断电时 `COM3` 也消失，串口监听重新打开后只捕获到 boot log 的后半段；开头 `[INFO] Booting`/config 行未保留。这是捕获限制，不是 boot 失败。
- 脱敏摘录：

```text
*wm:Connecting to SAVED AP: <saved-2.4GHz-network>
*wm:AutoConnect: SUCCESS
*wm:STA IP Address: <clock-ip>
[INFO] Connected to WiFi :)
*wm:Starting Web Portal
[INFO] Configuring OTA
[INFO] OTA password set to halclock<chip-id>
[INFO] OTA is ready
[INFO] Reset reason: REASON_DEFAULT_RST: normal startup by power on
```

- Web UI `http://<clock-ip>/` 返回 **HTTP 200**，页面 title 为 `HalClock`；LAN ping 可达。
- 捕获段内未见 boot loop 或 watchdog reset 行。
- 没有记录 SSID、IP、MAC 或 AP suffix。

## 7. 手动配置与刷后检查

- Maintainer 通过 Web UI 手动配置后反馈“时钟一切正常”；具体 timezone、NTP、brightness、display options 值未记录。
- 因此：手动配置/日常显示是 **人工反馈 PASS**，不是逐项硬件测试。
- OTA 初始化完成；OTA upload、Web UI firmware upload、power-loss、长期漂移、RTC-only fallback 未测试。
- Display segments/ghosting、自动亮度根因仍按原 [VALIDATION](../VALIDATION.md) 状态保持 partial/未验证。

## 8. 资格与边界

| 声称 | 状态 | 依据 |
|---|---|---|
| 第二台 K4-03 flash | **PASS** | 本文 §5；自动 + 独立 verify |
| 第二台 boot、Wi-Fi、Web UI | **PASS** | 本文 §6；串口 log + HTTP 200 |
| 第二台手动配置后运行 | **PASS（人工反馈）** | maintainer 反馈；具体值未记录 |
| 第二台 restore | **NOT_RUN** | backup 已验证，restore 未执行 |
| 第二台详细 display/RTC/auto-brightness | **NOT_RUN / UNKNOWN** | 未逐项测试 |
| OTA / Web UI upload | **NOT_RUN** | 未测试 |

本页不证明 K2-02 与 K4-03 电气等价，也不证明所有 K4-03 revision 相同。

## 9. 相关

- [2026-07-23 首台 K4-03 部署](2026-07-23-k4-03-deployment.md)
- [2026-07-23 backup manifest](2026-07-23-k4-03-backup-manifest.md)
- [2026-07-23 hardware preparation](2026-07-23-k4-03-hardware-preparation.md)
- [Deployment runbook](../modules/deployment/README.md)
- [Validation](../VALIDATION.md)
