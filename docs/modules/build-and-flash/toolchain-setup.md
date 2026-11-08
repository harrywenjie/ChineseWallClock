# Toolchain 重建（temp 可丢弃）

本页把 ignored 的 `temp/` 构建环境从零重建到 2026-07-23 / 2026-11-08 已验证的状态。仓库只保存可重建输入：源码、`libraries/libraries.zip`、CLI config、脚本和版本/hash；Arduino CLI、ESP8266 core、编译工具链、Python venv 不提交。`temp/` 可以整体删除。

## 1. 固定版本与来源

| 组件 | 版本 | 归档 bytes | SHA-256 | 落点 |
|---|---|---:|---|---|
| Arduino CLI Windows 64 | 0.35.3 | 15,548,385 | `B3B03C37DF87C99C9B201E4D4D5FB37F4F24E7441AC34510F5BB451DE1EDA35C` | `temp/toolchain/arduino-cli-0.35.3/` |
| ESP8266 core | 3.1.2 | 39,269,515 | `B3F47686D7783C120C2F10BF82788F921C53DB8642CC87012599ABB6E335B182` | `temp/arduino-data/packages/esp8266/hardware/esp8266/3.1.2/` |
| `xtensa-lx106-elf-gcc` | 3.1.0-gcc10.3-e5f9fec | 75,699,849 | `1456AA7509A68330517563EAF3F5806988B2076D992C42ECBA06FCEF5918903C` | `temp/arduino-data/packages/esp8266/tools/` |
| `mkspiffs` | 3.1.0-gcc10.3-e5f9fec | 350,354 | `BE6E0CBBA1E3E8B9814A4D39EAC52E197364EE547D5C1B45B4931054930934F5` | 同上 |
| `mklittlefs` | 3.1.0-gcc10.3-e5f9fec | 347,602 | `ECF3B1351A1B174282D11B5E953FA338B4ABEE5C51F838692844939D57C32203` | 同上 |
| `python3`（core 依赖） | 3.7.2-post1 | 6,428,926 | `F57CB2DAF86176D2929E7C58990C2AC32554E3219D454DCAC10E464DDDA35BF2` | 同上 |
| `libraries/libraries.zip` | tracked 快照 | 12,334,448 | `E92457AAE7DCCE9591787C9240D9D468B99E711AA15912361B62EB900ECBDD07` | `temp/bundled/libraries/` |
| esptool（刷写，可选） | 5.3.1 | — | — | Python 环境 |
| PyMuPDF / pypdf（schematic，可选） | 1.26.3 / 6.1.1 | — | — | `temp/pdf-venv/` |

归档 URL：

```text
https://downloads.arduino.cc/arduino-cli/arduino-cli_0.35.3_Windows_64bit.zip
https://github.com/esp8266/Arduino/releases/download/3.1.2/esp8266-3.1.2.zip
https://github.com/earlephilhower/esp-quick-toolchain/releases/download/3.1.0-gcc10.3/x86_64-w64-mingw32.xtensa-lx106-elf-e5f9fec.220621.zip
https://github.com/earlephilhower/esp-quick-toolchain/releases/download/3.1.0-gcc10.3/x86_64-w64-mingw32.mkspiffs-7fefeac.220621.zip
https://github.com/earlephilhower/esp-quick-toolchain/releases/download/3.1.0-gcc10.3/x86_64-w64-mingw32.mklittlefs-30b7fc1.220621.zip
https://github.com/earlephilhower/esp-quick-toolchain/releases/download/2.5.0-4/python3-3.7.2.post1-embed-win32v2a.zip
```

Arduino CLI 的 hash 与官方 checksum 列表一致；core 和工具 hash 来自 ESP8266 package index。`arduino-cli core install` 会按 index 下载并校验这些归档。

## 2. 一键重建

```powershell
pwsh -NoProfile -File scripts/setup-build-env.ps1
pwsh -NoProfile -File scripts/build-firmware.ps1 -Variant canonical1 -Clean
```

`setup-build-env.ps1` 创建 `temp/` 目录，下载/校验/解压 Arduino CLI，`core update-index` + `core install esp8266:esp8266@3.1.2`，解压 `libraries/libraries.zip` 到 `temp/bundled`，最后检查 esptool。已有组件会跳过；`-Force` 重新下载 CLI 和解压库，`-SkipCore` / `-SkipLibraries` 用于 dry run。需要网络下载缺失的包。

`build-firmware.ps1` 固定 FQBN `esp8266:esp8266:d1_mini`、`temp/bundled/libraries`、`build.warn_data_percentage=75` 和 `SOURCE_DATE_EPOCH=1711661163`，用绝对 `temp/build/canonical1` 路径，日志写 `temp/logs/`，并打印 image size/SHA-256。`-Clean` 用于可复现重建。

验证：

```powershell
temp\toolchain\arduino-cli-0.35.3\arduino-cli.exe --config-file scripts\arduino-cli.yaml core list
Get-FileHash temp\artifacts\canonical1\ChineseWallClock.ino.bin -Algorithm SHA256
```

期望 `esp8266:esp8266 3.1.2`；用上面的 epoch/flags 重建出的 image 应为 **485,280 bytes**，SHA-256 `5E4F281421DCE894FED3F03DD9599AF8A690218A85C70B6A5A5DB466748D3D1D`。2026-11-08 用不同 build path（`scriptcheck`）和空 `temp/` 副本都得到同一 hash。

## 3. 手动步骤

1. 下载 CLI zip 到 `temp/downloads/`；用 `Get-FileHash -Algorithm SHA256` 对照上表，`Expand-Archive` 到 `temp/toolchain/arduino-cli-0.35.3/`，确认 `arduino-cli.exe version` 是 0.35.3。
2. 使用 tracked [`scripts/arduino-cli.yaml`](../../../scripts/arduino-cli.yaml)。它把 data/downloads/user 指向 `temp/`；相对路径从仓库根解析，所以命令必须在仓库根运行。
3. `core update-index`，再 `core install esp8266:esp8266@3.1.2`。两步都带 `--config-file scripts\arduino-cli.yaml`。
4. 解压 `libraries/libraries.zip` 到 `temp/bundled`。zip 顶层是 `libraries/`，所以结果是 `temp/bundled/libraries/`；解压后应有 18 个库目录。
5. Build（与脚本等价）：

   ```powershell
   $env:SOURCE_DATE_EPOCH = '1711661163'
   & temp\toolchain\arduino-cli-0.35.3\arduino-cli.exe `
     --config-file scripts\arduino-cli.yaml `
     compile `
     --fqbn esp8266:esp8266:d1_mini `
     --libraries temp\bundled\libraries `
     --build-path temp\build\canonical1 `
     --output-dir temp\artifacts\canonical1 `
     --build-property build.warn_data_percentage=75 `
     --clean .
   ```

6. 刷写工具：`python -m pip install esptool==5.3.1`，用 `python -m esptool version` 核对。
7. 可选 schematic：`python -m venv temp\pdf-venv`，用 venv 的 Python 安装 `PyMuPDF==1.26.3 pypdf==6.1.1`，从仓库根运行 [`render_schematic.py`](../../evidence/2026-07-23-fork-build/render_schematic.py)，输出到 `temp/pdfs/`。

## 4. 边界与限制

- 下载 URL、package index 和 GitHub 必须可达；仓库不保存这些归档，也不保存 index 快照。网络/上游不可用时重建会失败，不能当作已重建。
- `5E4F…D3D1D` 在 `E:\ChineseWallClock` 上固定 epoch/toolchain/libraries 得到；`scriptcheck` build path 和 `E:\cwc\ChineseWallClock` 空 `temp/` 副本也匹配，workspace 路径未观察到影响。其他情况比较 size、memory 和实际行为，不要只比 hash。
- Sketch/workspace 目录名必须是 `ChineseWallClock`（Arduino 找同名 `.ino`）；build 放短路径。约 209 字符的嵌套路径曾报 `bits/cpu_defines.h` 缺失，缩短后通过，根因未深究。
- 2026-07-23 也下载过 Arduino CLI 1.5.1 和 Arduino IDE 2.3.2 source；它们没有参与保留 build，重建不需要。
- 本页只到 compile。flash、boot、display、Wi-Fi、OTA 是独立证据等级，见 [deployment runbook](../deployment/README.md) 和 [K4-03 deployment](../../evidence/2026-07-23-k4-03-deployment.md)。

相关：[build 与刷写](README.md)、[fork build 证据](../../evidence/2026-07-23-fork-build/README.md)、[2026-11-08 local build](../../evidence/2026-11-08-local-build.md)、[temp 盘点](../../maintenance/2026-11-08-temp-inventory.md)。
