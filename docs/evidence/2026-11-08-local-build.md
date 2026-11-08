# 2026-11-08 本地 Build 证据

本页记录文档迁移轮执行的 compile。它只是 local compile；没有连接设备，没有刷写。

## 1. 输入

- 源码：`d55188e`（upstream HEAD；没有 fork code changes）。
- Build 前 working tree：clean。
- Toolchain：Arduino CLI 0.35.3、ESP8266 core 3.1.2。
- Libraries：`temp/bundled/libraries`，从 `libraries/libraries.zip` 解压。
- Board：`esp8266:esp8266:d1_mini`（Wemos D1 mini / ESP-12F target）。

## 2. 命令

在 Windows 11 的仓库根执行：

```text
& 'temp\toolchain\arduino-cli-0.35.3\arduino-cli.exe' \
  --config-file temp\arduino-cli.yaml \
  compile \
  --fqbn esp8266:esp8266:d1_mini \
  --libraries temp\bundled\libraries \
  --build-path temp\build\docs-verify \
  --output-dir temp\artifacts\docs-verify \
  .
```

PowerShell 用 `*> temp\logs\docs-verify.log` 重定向；exit 0。

`temp\arduino-cli.yaml` 是当时的本地 config；可移植版本在 [`scripts/arduino-cli.yaml`](../../scripts/arduino-cli.yaml)，从零重建步骤见 [toolchain setup](../modules/build-and-flash/toolchain-setup.md)。

## 3. 结果

| 产物 | Bytes | SHA-256 |
|---|---|---|
| `ChineseWallClock.ino.bin` | 485,280 | `4898BF9BCBC4A510E986CD5E6F3207AB56E3DFB6A18EE0DC090811BE784950C6` |
| `ChineseWallClock.ino.elf` | 7,910,144 | `30F9B311CCAC40435E8A7FCED01F547BC394DF507ED3CE3ABA0B779C77E2B273` |
| `ChineseWallClock.ino.map` | 4,703,776 | `69AB26E23B6E564E4A826F697A9C724DCE9D2881F7D3BC098AE3B8A7C9779A02` |

Memory：RAM 37,404 / 80,192（46 %），IRAM 62,551 / 65,536（95 %），flash 443,980 / 1,048,576（42 %）。

Warning：项目代码 14 个 `-Wwrite-strings` warning，无 error。Log 里还有 Arduino CLI core-cache path warning（`Couldn't deeply cache core build: ...`），由 workspace temp path 引起，不影响 build。

## 4. 对比

| Image | Bytes | SHA-256 |
|---|---|---|
| v1.1 release（2024-04-01） | 485,248 | `1FB0CBA700ABF0A0E40269F0E3E318C88EC17D31ED82C11954014293D62129FC` |
| 2026-07-23 canonical（固定 epoch） | 485,280 | `5E4F281421DCE894FED3F03DD9599AF8A690218A85C70B6A5A5DB466748D3D1D` |
| 本 build（未固定 epoch） | 485,280 | `4898BF9BCBC4A510E986CD5E6F3207AB56E3DFB6A18EE0DC090811BE784950C6` |

当前源码与 v1.1 code-identical，但 image 大 32 bytes。这不是 byte-identical rebuild；原因 **UNKNOWN**（toolchain/library patch 或 build flag）。实际部署 build 使用 `SOURCE_DATE_EPOCH=1711661163`，记录在 [K4-03 deployment](2026-07-23-k4-03-deployment.md)；本 build 没设该 epoch，hash 不能直接比较。

## 5. 证据文件

- [`2026-11-08-local-build.log`](2026-11-08-local-build.log) — 完整 console log（6,787 bytes）。
- [`2026-11-08-local-build.sha256`](2026-11-08-local-build.sha256) — artifact 和 log hash。

Binary/ELF/map 是本地构建产物，不提交；需要时按 [toolchain setup](../modules/build-and-flash/toolchain-setup.md) 重建。2026-11-08 的 `scriptcheck` 用不同 build path、并在 `E:\cwc\ChineseWallClock` 空 `temp/` 副本重建，均复现部署 hash；说明本 toolchain 上 build path/workspace 未改变 `.bin`（长路径例外见 §8）。先比 size 和 memory，再比 hash。

## 6. 边界

本证据证明 documented toolchain 能编译当前源码。§2–§5 的 build 没固定 epoch，不证明与部署 image 相同；§7 的 `scriptcheck` 重建匹配部署 hash，但仍只是 local compile。它**不**证明 image 能 boot、能刷写、能驱动 display、能连 WiFi、能同步时间、能过 OTA。这些是单独的 hardware/deployment 资格。

## 7. 同轮 toolchain 脚本复现

在已有 `temp/` 上用 [`scripts/build-firmware.ps1`](../../scripts/build-firmware.ps1) 重建：

```text
pwsh -NoProfile -File scripts/build-firmware.ps1 -Variant scriptcheck -Clean
```

- 输入：CLI 0.35.3、core 3.1.2、`temp/bundled/libraries`、`SOURCE_DATE_EPOCH=1711661163`、`build.warn_data_percentage=75`。
- Build path：`temp/build/scriptcheck`（与部署 build 的 `canonical1` 不同）。
- exit 0；image **485,280 bytes**，SHA-256 `5E4F281421DCE894FED3F03DD9599AF8A690218A85C70B6A5A5DB466748D3D1D`，与 2026-07-23 部署 image 相同。
- Memory：RAM 37,404 / 80,192（46 %），IRAM 62,551 / 65,536（95 %），flash 443,980 / 1,048,576（42 %）。
- 边界：local compile only；证明脚本和现有 toolchain 能重建部署 image，不证明硬件或刷写。

## 8. 空 temp 重建（复制 workspace）

在 `E:\cwc\ChineseWallClock` 创建只含 sketch 源码、`libraries/libraries.zip` 和 `scripts/` 的副本（没有预置 `temp/`），运行：

```text
pwsh -NoProfile -File scripts/setup-build-env.ps1
pwsh -NoProfile -File scripts/build-firmware.ps1 -Variant canonical1 -Clean
```

- Setup 全量下载并安装：Arduino CLI 0.35.3、core 3.1.2、xtensa gcc/mkspiffs/mklittlefs/python3、18 个库；exit 0；esptool 5.3.1。
- Build exit 0；image **485,280 bytes**，SHA-256 `5E4F281421DCE894FED3F03DD9599AF8A690218A85C70B6A5A5DB466748D3D1D`，与部署 image 相同；RAM/IRAM/flash 与 §7 相同。
- 副本的绝对路径与部署 workspace 不同，hash 仍匹配；说明本次 toolchain 上 `.bin` 未受该路径影响。
- 测试副本运行后删除，日志不提交；网络必须可达。离线重建仍是 **NOT_RUN**。
- 先在 `E:\ChineseWallClock\temp\fresh-check\ChineseWallClock`（约 209 字符嵌套路径）尝试时，GCC 报 `bits/cpu_defines.h` 缺失；缩短到 `E:\cwc\ChineseWallClock` 后通过。根因未深究，build 应放短路径。
- 测试副本目录名必须是 `ChineseWallClock`：在 `temp\rebuild-check` 下 Arduino 报 `main file missing ... rebuild-check.ino`。这是 sketch 目录名规则，不是 toolchain 缺陷。

本页 §7 和 §8 都只是 local compile；不证明 image 能 boot、刷写或驱动时钟。
