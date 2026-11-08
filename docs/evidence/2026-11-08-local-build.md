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

当前源码与 v1.1 code-identical，但 image 大 32 bytes。这不是 byte-identical rebuild；原因 **UNKNOWN**（toolchain/library patch、build flag 或 build-path effect）。实际部署 build 使用 `SOURCE_DATE_EPOCH=1711661163`，记录在 [K4-03 deployment](2026-07-23-k4-03-deployment.md)；本 build 没设该 epoch，hash 不能直接比较。

## 5. 证据文件

- [`2026-11-08-local-build.log`](2026-11-08-local-build.log) — 完整 console log（6,787 bytes）。
- [`2026-11-08-local-build.sha256`](2026-11-08-local-build.sha256) — artifact 和 log hash。

Binary/ELF/map 仍在 `temp/artifacts/docs-verify/`，未提交。需要时按上面命令重建；先比 size 和 memory，只有相同 path/toolchain 才比 hash。

## 6. 边界

本证据证明 documented toolchain 能编译当前源码。它**不**证明 image 能 boot、能刷写、能驱动 display、能连 WiFi、能同步时间、能过 OTA，也不证明与 fork 实际部署 image 相同。这些是单独的 hardware/deployment 资格。
