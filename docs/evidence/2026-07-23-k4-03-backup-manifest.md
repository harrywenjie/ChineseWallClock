# 2026-07-23 K4-03 Backup 清单

本页记录实际 K4-03 factory backup 和它的处理方式。原始 image **不复制进、不提交到**这个公开仓库，因为它包含已保存的 Wi-Fi 配置和硬件标识，不只是固件。Maintainer 自行保存和手动备份。

## 1. 备份

| 属性 | 值 |
|---|---|
| 原始私有目录 | `<private-backup-dir>`（仓库外；不要公开） |
| Verified 文件 | `K4-03_FACTORY_VERIFIED.bin` |
| 大小 | **4,194,304 bytes**（`0x400000`，完整 4 MiB） |
| SHA-256 | `59FC45E91B37DCAD5C4E60E90416E3351D303A7CB8739B791CBD999FDC0CA37E` |
| 历史读取 | 两次 independent full read（`K4-03_factory_1.bin`、`K4-03_factory_2.bin`），size/hash 一致 |
| Restore note | 私有目录中的 `restore.txt` |
| Restore 测试 | **未执行**——restore 命令是预案，不是 verified operation |

私有目录还包含 `K4-03_FACTORY_VERIFIED.sha256.txt` 和 `restore.txt`。它们因含私有路径/用户上下文，不提交。

### 内容检查

对 verified image 做只读检查，在 SDK 参数区找到已保存的 Wi-Fi 配置：

- 已知 SSID 字符串出现在 offset `0x3FD010`，并在 `0x3FE010` 重复；这是 SDK Wi-Fi config 区，不是 application image；
- 同一结构后面有 credential-like 字段；具体编码未解码，本页不复制任何 secret；
- 最后 16 KiB 的其余内容是 SDK/RF 数据，不只是 application code。

所以 backup **不是** firmware-only。即使 password 编码没有 reverse-engineer，整份 4 MiB image 也要按含用户设置处理。

## 2. 仓库策略

- 原始 image 只放私有目录和 maintainer 选择的离线 backup。
- **不**复制进仓库；没有 `archive/` 目录或 Git-tracked binary。
- 只提交本清单、size/hash 和 restore procedure。
- 如果仓库以后改为 private，且 maintainer 明确接受凭据暴露，才可以单独提交 raw image；当前政策不是这样。

Maintainer 会自行做 manual backup；本页不声称存在第二份副本。

## 3. 恢复命令（仅预案）

时钟正常运行时不要执行。它把完整私有 image 从 `0x000000` 写回：

```powershell
py -m esptool --chip esp8266 --port COM3 --baud 115200 `
  --before no-reset --after no-reset `
  write-flash 0x000000 `
  <private-backup-dir>\K4-03_FACTORY_VERIFIED.bin
```

执行前：

1. 复核 SHA-256 和 size。
2. 确认是同一台 K4-03（不要用 upstream K2-02 image）。
3. 确认 GPIO0 low，时钟已重新上电进 bootloader。
4. 确认 `COM3` 没被 serial monitor 占用。
5. 取得明确批准；restore 尚未测试。

写完后 verify flash，断电，移除 GPIO0 到 GND，重新上电，检查原厂 display、Wi-Fi 和 Web 页面。

## 4. 为什么 raw image 不进 Git

完整 flash 含已保存的 Wi-Fi 配置和 unit-specific 数据。仓库是 public。提交会暴露私有网络设置，并在 Git history 留下难以移除的副本。安全处理是：

- verified raw image 只放私有目录/离线 backup；
- 提交本清单、size/hash 和 restore procedure；
- 不要把 image 附到 issue、release 或 pull request。

## 5. 相关记录

- [K4-03 deployment](2026-07-23-k4-03-deployment.md)
- [K4-03 hardware preparation](2026-07-23-k4-03-hardware-preparation.md)
- [Factory firmware](../modules/factory-firmware/README.md)
- [Deployment runbook](../modules/deployment/README.md)

第二台 K4-03 也有独立的 per-unit backup（SHA-256 `5F90…C01D`）；见 [2026-11-11 second-unit deployment](2026-11-11-k4-03-second-unit-deployment.md)。两台 backup 不能交叉使用。
