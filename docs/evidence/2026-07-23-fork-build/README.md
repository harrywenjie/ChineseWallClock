# 2026-07-23 Fork Build 证据

本目录保留 fork 本地 build session，原本在 `temp/`，如果临时目录清理会丢失。文件从 `temp/` 原样复制；里面的绝对路径指向原 workspace（`E:\ChineseWallClock`），不可移植。

## 1. 做了什么

2026-07-23 在 upstream `d55188e` clone fork，把 Arduino toolchain 装进 `temp/`，解压固定 libraries，渲染 schematic，产出五个 build variant。目的看起来是复现 upstream release；没有 variant 与 v1.1 byte-identical。

- 日期：2026-07-23 workspace local time（UTC+12）。
- 源码：`d55188e`（2025-07-25），没有 fork code changes。
- Build：exit 0；无 compiler error。
- Full image：每个 variant 都是 485,280 bytes。
- 最终 deterministic build：`SOURCE_DATE_EPOCH=1711661163`；`canonical1` 和 `canonical2` 产出 byte-identical image，SHA-256 `5E4F281421DCE894FED3F03DD9599AF8A690218A85C70B6A5A5DB466748D3D1D`。`canonical1` 是实际刷入 K4-03 的 image。
- v1.1 release：485,248 bytes（小 32 bytes）；原因 **UNKNOWN**。

## 2. 环境

| 项目 | 值 |
|---|---|
| OS | Windows 11 |
| 使用 Arduino CLI | 0.35.3（`95cfd654`，2024-02-19） |
| 也下载了 | 1.5.1（未用于保留的 build） |
| ESP8266 core | 3.1.2 |
| FQBN | `esp8266:esp8266:d1_mini` |
| Board manager URL | `https://arduino.esp8266.com/stable/package_esp8266com_index.json` |
| Compiler | `xtensa-lx106-elf-gcc` 3.1.0-gcc10.3-e5f9fec |
| Libraries | `libraries/libraries.zip` 解压到 `temp/bundled/libraries` |
| PDF 工具 | PyMuPDF 1.26.3、pypdf 6.1.1 |
| Build 输出 | RAM 37,404 / 80,192（46 %），IRAM 62,551 / 65,536（95 %），flash 443,980 / 1,048,576（42 %） |

完整记录见 [`environment.txt`](environment.txt)。

## 3. 命令

Exact `arduino-cli` invocation 没有 log。Compiler log 和 `build.options.json` 保留 FQBN、library folders、custom build properties；compiler command line 在 log 里。可重建为：

```text
arduino-cli core install esp8266:esp8266@3.1.2
arduino-cli compile --fqbn esp8266:esp8266:d1_mini \
  --libraries <repo>/temp/bundled/libraries \
  --build-path <repo>/temp/build/<variant> \
  --output-dir <repo>/temp/artifacts/<variant> \
  <repo>
```

最终 deterministic build 设置 `SOURCE_DATE_EPOCH=1711661163`。canonical/IDE-like variant 的 build options 记录 `build.warn_data_percentage=75`。不要把这个重建命令当成 exact replay；使用记录的 library 版本和当前 [build 指令](../../modules/build-and-flash/README.md)。

## 4. 构建变体

| 变体 | Build 目录 | Custom build property | 完整 image | App-only image |
|---|---|---|---|---|
| default | `temp/build/default` | none | 485,280 B / `e059dada…` | 481,184 B / `8afa2544…` |
| repro2 | `temp/build/repro2` | none | 485,280 B / `52038606…` | 481,184 B / `06d42a0e…` |
| ide232-cli | `temp/build/ide232-cli` | `build.warn_data_percentage=75` | 485,280 B / `c935403d…` | — |
| canonical1 | `temp/build/canonical1` | `build.warn_data_percentage=75` | 485,280 B / `5e4f2814…` | 最终 deterministic build；已刷入 |
| canonical2 | `temp/build/canonical2` | `build.warn_data_percentage=75` | 485,280 B / `5e4f2814…` | 不同 build path 的 repeat |

完整 hash/size 在 [`build-options.tsv`](build-options.tsv) 和 [`artifacts.sha256`](artifacts.sha256)。App-only image 是 full image 去掉前 4,096 bytes，不是独立 firmware。

## 5. 保留文件

| 文件 | 内容 |
|---|---|
| [`build-default.log`](build-default.log) | `default` build 的完整 compiler log（707,561 bytes） |
| [`build-canonical-ide232-cli.log`](build-canonical-ide232-cli.log) | IDE-like canonical build 的 compiler log（72,791 bytes） |
| [`arduino-cli.yaml`](arduino-cli.yaml) | Local CLI config，含绝对 `temp/` 路径 |
| [`render_schematic.py`](render_schematic.py) | PyMuPDF/pypdf 渲染 schematic 的脚本 |
| [`arduino-cli_0.35.3-checksums.txt`](arduino-cli_0.35.3-checksums.txt) | 下载 archive 的官方 checksum 列表 |
| [`artifacts.sha256`](artifacts.sha256) | fork build artifact、inherited release、factory dump 的 hash/size |
| [`environment.txt`](environment.txt) | 环境摘要 |
| [`build-options.tsv`](build-options.tsv) | 每个 variant 的 build options 和 image hash |
| [`library-versions.tsv`](library-versions.tsv) | 固定 zip 里的 library 版本和是否使用 |
| [`preserved-files.sha256`](preserved-files.sha256) | 本目录的 integrity manifest |

## 6. 没有复制的内容

源 `temp/` 很大且 machine-specific。以下有记录但不提交，仍在原 workspace（或可重建）：

| `temp/` 项 | 内容 | 处置 |
|---|---|---|
| `arduino-data/` | ESP8266 core 3.1.2、package metadata、toolchain 组件 | 版本和 URL 已记；不复制（数百 MB） |
| `arduino-downloads/` | Arduino CLI download cache | 不复制；可重新下载 |
| `artifacts/` | build `.bin`/`.elf`/`.map` | size/SHA-256 在 [`artifacts.sha256`](artifacts.sha256)；binary 不复制 |
| `build/` | 每个 variant 的 build tree 和 generated source | compiler log 已复制；build options 已摘要；tree 不复制 |
| `bundled/` | 解压的 libraries 和 Arduino user directory | 与 `libraries/libraries.zip` 逐文件对比；不复制 |
| `downloads/` | Arduino CLI/IDE archive 和 checksum | checksum 文件已复制；archive 不复制 |
| `ide-source-2.3.2/` | Arduino IDE 2.3.2 source tree | 版本/size 已记；不复制 |
| `pdf-venv/` | Python virtualenv（PyMuPDF 1.26.3、pypdf 6.1.1） | package 版本已记；不复制 |
| `pdfs/` | 渲染的 schematic：page 1 300 dpi 和两个 600 dpi crop | 脚本已复制；PNG 不复制 |
| `toolchain/` | Arduino CLI 0.35.3、1.5.1 executable | 版本已记；不复制 |

如果原 `temp/` 删除，可按 vendored `libraries/libraries.zip`、记录的 core/board URL、复制的 log/config 和本页命令重建。Raw log 是 exact compiler command line 的唯一记录。

## 7. 限制

- Exact command 和 variant 命名原因没有 log；重建是根据 build options 和 log 推断。
- Log 含绝对路径和 Windows user temp path；作为证据保留，不是 portable script。
- 本 build evidence 没有 flash/boot log。实际 K4-03 部署在 [2026-07-23 K4-03 deployment](../2026-07-23-k4-03-deployment.md)；build 本身只证明 compile。
- 没有 variant 匹配 v1.1 release。差异在 [validation](../../VALIDATION.md#release-rebuild) 记为 **UNKNOWN**；不要声称 byte-identical 复现。
- Inherited release 和 factory dump 放入 hash manifest 只用于对比，不是 fork 产物。

## 8. 完整性检查

从仓库根：

```text
Get-Content docs/evidence/2026-07-23-fork-build/preserved-files.sha256
```

Manifest 列出文件名、size、SHA-256。复制的 log/config 是 immutable evidence；如果主动替换文件，记录原因并更新 manifest，不要静默改。
