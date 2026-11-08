# scripts

仓库自带的可复现工具。它们只负责检查文档、重建 `temp/` 构建环境和 compile；不刷写、不部署、不改固件行为。

| 文件 | 用途 |
|---|---|
| [`check_docs.py`](check_docs.py) | 检查 tracked Markdown 的本地链接/anchor，并输出入口、design/validation 导航和 module 页面的容量。从仓库任意位置运行 `python scripts/check_docs.py`。 |
| [`setup-build-env.ps1`](setup-build-env.ps1) | 下载并校验 Arduino CLI 0.35.3、安装 ESP8266 core 3.1.2、解压 `libraries/libraries.zip` 到 `temp/`。幂等；`-Force` 重新下载 CLI/解压库。 |
| [`build-firmware.ps1`](build-firmware.ps1) | 用固定 FQBN、libraries、build properties 和 `SOURCE_DATE_EPOCH` compile；打印 image size/SHA-256，并与 2026-07-23 部署 image 比较。 |
| [`arduino-cli.yaml`](arduino-cli.yaml) | 可移植 CLI config。相对路径从仓库根解析；不要从其他目录运行。 |

版本、下载 URL、SHA-256 和手动步骤在 [toolchain 重建](../docs/modules/build-and-flash/toolchain-setup.md)。`temp/` 是 ignored、可整体删除的构建环境；这些脚本是清理后重建的入口。
