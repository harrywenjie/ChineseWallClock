# 构建、镜像与刷写

本页是当前源码的 build/flash 合同。它记录 upstream 环境、已验证的 fork build、image 形式和刷写路径。部署流程见 [deployment](../deployment/README.md)，硬件接线见 [hardware](../hardware/README.md)。

## 1. 环境

upstream README 记录：

- Ubuntu 22.04.4 LTS（jammy）
- Arduino IDE 2.3.2
- Wemos D1 mini 作为开发/测试板

fork 的已验证 build（2026-07-23 和 2026-11-08）使用：

- Windows 11
- Arduino CLI **0.35.3**
- ESP8266 core **3.1.2**
- 从 `libraries/libraries.zip` 解压出的 libraries

target FQBN 是 `esp8266:esp8266:d1_mini`。物理时钟用 ESP-12F；D1 mini 是原作者使用的兼容开发板。

实际 fork 部署在 **K4-03**，不是 upstream K2-02。最终 build 使用 Arduino CLI 0.35.3 和 `SOURCE_DATE_EPOCH=1711661163`；两次 clean build byte-identical，产出 485,280-byte image `5E4F2814…D3D1D`。见 [K4-03 deployment](../../evidence/2026-07-23-k4-03-deployment.md)。

## 2. 库

`libraries/libraries.zip` 是作者的固定库快照（12,334,448 bytes，18 个库）。它是 backup，不是 package manifest。解压到 libraries 目录并传给 build；不要用 latest 版本覆盖。

已验证 build 实际使用：

| 库 | 版本 | 来源 |
|---|---|---|
| WiFiManager | 2.0.17 | bundle |
| ArduinoJson | 7.0.4 | bundle |
| SimpleSyslog | 0.1.1 | bundle |
| AceWire | 0.4.1 | bundle |
| AceTimeClock | 1.3.0 | bundle |
| AceTime | 2.3.1 | bundle |
| AceCommon | 1.6.2 | bundle |
| AceSorting | 1.0.0 | bundle |
| ESP8266WiFi、ESP8266WebServer、DNSServer、LittleFS、ArduinoOTA、Wire、ESP8266mDNS | core 3.1.2 | ESP8266 platform |

zip 还包含 sketch 不用的库（如 Timezone、ESP32httpUpdate、ESP-WiFiSettings），它们是作者 backup，不是最小 build 必需。见 [libraries/README.md](../../../libraries/README.md)。

## 3. Arduino IDE

1. 安装 Arduino IDE 2.3.2 和 ESP8266 board package **3.1.2**。
2. 在 Additional Boards Manager URLs 加 `https://arduino.esp8266.com/stable/package_esp8266com_index.json`。
3. 把 `libraries/libraries.zip` 解压到 Arduino libraries 目录（或 sketchbook-local `libraries`）。
4. 打开 `ChineseWallClock.ino`。
5. 选择 **Wemos D1 mini**（`esp8266:esp8266:d1_mini`）、正确 port、4 MB flash 设置和 serial upload speed。
6. Verify/compile，然后 serial upload，或用 Arduino IDE network port 做 OTA。

Web UI 截图只是参考媒体，不是 build 指令。

<a id="arduino-cli"></a>

<a id="arduino-cli"></a>

## 4. Arduino CLI

安装 core、解压库：

```text
arduino-cli core install esp8266:esp8266@3.1.2
arduino-cli config add board_manager.additional_urls https://arduino.esp8266.com/stable/package_esp8266com_index.json
```

从仓库根目录 build（sketch 就是目录）：

```text
arduino-cli compile \
  --fqbn esp8266:esp8266:d1_mini \
  --libraries <path-to-extracted-libraries> \
  --build-path temp/build/verify \
  --output-dir temp/artifacts/verify \
  .
```

2026-11-08 的 Windows 命令原样记录在 [local build evidence](../../evidence/2026-11-08-local-build.md)；它使用 local `temp/arduino-cli.yaml`、`temp/arduino-data`、`temp/bundled/libraries`、`temp/build/docs-verify`。这些路径是 workspace-local，不提交。

和部署 image 做可复现比较时，在 build 环境设 `SOURCE_DATE_EPOCH=1711661163`。2026-07-23 部署 build 使用该 epoch 和 Arduino CLI 0.35.3；两次 clean build 产出 byte-identical 的 `canonical1`/`canonical2`，SHA-256 `5E4F281421DCE894FED3F03DD9599AF8A690218A85C70B6A5A5DB466748D3D1D`。不固定 epoch 时 ESP8266 core 会嵌入当前时间，hash 变化（见 2026-11-08 build）。

### 输出和大小

成功 build 报告：

- RAM：37,404 / 80,192 bytes（46 %）
- IRAM：62,551 / 65,536 bytes（**95 %**）
- Flash：443,980 / 1,048,576 bytes（42 %）
- 完整 image：**485,280 bytes**
- 14 个 `-Wwrite-strings` warning，无 error

IRAM 是紧张资源。每次改动都重跑 size report；小功能也可能先撞 IRAM。

## 5. Image 形式与 offset

有两类文件：

| 形式 | 开头 | 已验证 build 大小 | 目标 offset | 来源 |
|---|---|---|---|---|
| 完整 Arduino image（`ChineseWallClock.ino.bin`） | `e9 02 02 40` header at 0x0000 | 485,280 bytes | `0x0000` | 正常 Arduino/`elf2bin` 输出；`releases/` 也是这种 |
| App-only image（`app-at-0x1000.bin`） | `e9 05 02 40` header at 0x0000 | 481,184 bytes | `0x1000`（bootloader 已存在时） | 完整 image 的 `0x1000..end` |

不要混用。完整 image 写到 `0x1000`，或 app-only 写到 `0x0000`，都不会 boot。部署记录必须写清文件、hash 和 offset。`releases/` 里的 binary 是完整 image；fork 的 temp evidence 里有 app-only 派生 image 用于对比。

## 6. 刷写路径

- **Serial（恢复首选）：** 3.3 V USB-TTL 接 6-pin header，进 ESP8266 boot mode（通常 `FLASH` low + pulse `RST`；以板子为准），完整 image 写 `0x0000` 或 app-only 写 `0x1000`。115200 捕获完整 serial log。
- **实际 K4-03：** CP210x 在 `COM3`；只接 GND/TX/RX；时钟自己 USB-A 供电；没有 RST/DTR/RTS。GPIO0 拉低后重新上电，所以 esptool 用 `--before no-reset --after no-reset`、115200 baud。写入用 `--flash-mode keep --flash-freq keep --flash-size keep`，不做 full-chip erase，然后自动 + 独立 `verify-flash`。见 [K4-03 deployment](../../evidence/2026-07-23-k4-03-deployment.md)。
- **Arduino OTA：** 定义 `ENABLE_OTA` 时，设备出现在 network port；password 是 AP 名（`halclock<chipid>`）。设备必须已在同一网络。OTA progress 会喂 watchdog。
- **Web UI firmware upload：** upstream README 报告 broken。复现并修好前，不要作为部署路径。

factory firmware 是 **full-flash-style dump**（partial：4,000,000 bytes），不是 Arduino app image；恢复是另一套操作。见 [factory firmware](../factory-firmware/README.md)。

## 7. 可复现性发现

- 当前源码与 v1.1 code-identical（`git diff 7d18e68..HEAD` 不改 `.ino`、`.cpp`、`.h`），但已验证 build 是 **485,280 bytes**，v1.1 release 是 **485,248 bytes**。
- 当前源码在固定 `SOURCE_DATE_EPOCH=1711661163` 和 Arduino CLI 0.35.3 下可复现：两次 clean `canonical` build byte-identical（`5E4F…D3D1D`）。这是实际刷入的 image。
- 2026-07-23 的 `default`、`repro2`、`ide232-cli`、`canonical1`、`canonical2` 都产出 485,280-byte 完整 image。与 v1.1 的 32-byte 差异为 **UNKNOWN**；可能是 core/library patch 或 build flag。
- build path 的内容/长度可能改变 image hash 而大小不变。只在相同 path/toolchain/epoch 下比较 hash；否则比较 size、memory report 和实际行为。
- 上一轮用 Arduino IDE 2.3.2 options + Arduino CLI 0.35.3；1.5.1 下载但未使用。没有 variant 与 v1.1 byte-identical。见 [2026-07-23 fork build](../../evidence/2026-07-23-fork-build/README.md)。

## 8. 常见故障

| 现象 | 可能原因 | 检查 |
|---|---|---|
| `WiFiManager.h: No such file` | libraries 目录没传或 zip 没解压 | `--libraries` 路径下有 `WiFiManager/library.properties` |
| Board/core 错误 | ESP8266 core 不是 3.1.2 | `arduino-cli core list` |
| 刷完不 boot | image 形式/offset 错 | 完整 `0x0000`，app-only `0x1000`；记录 hash |
| 进不了 boot mode | header 方向或 `FLASH`/`RST` 接线 | 照片、schematic、通断；3.3 V 电平 |
| OTA port 不出现 | 设备不在 WiFi、OTA 未启用、password 错 | serial log、`ENABLE_OTA`、AP 名 |
| Web upload 失败 | 已知 upstream 缺陷 | 用 serial 或 OTA；不要盲重试 |
| 改动后 IRAM overflow | IRAM 已 95 % | size report；减少代码或把数据移到 flash |
