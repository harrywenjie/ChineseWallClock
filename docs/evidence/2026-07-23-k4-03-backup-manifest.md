# 2026-07-23 K4-03 Backup Manifest

This page records the actual K4-03 factory backup and its handling. The raw image is **not copied into or committed to** this public repository because it contains the saved Wi-Fi configuration and hardware identifiers, not just firmware. The maintainer keeps and backs it up manually.

## 1. Backup

| Property | Value |
|---|---|
| Original private directory | `<private-backup-dir>` (kept outside the repository; do not publish) |
| Verified file | `K4-03_FACTORY_VERIFIED.bin` |
| Size | **4,194,304 bytes** (`0x400000`, full 4 MiB) |
| SHA-256 | `59FC45E91B37DCAD5C4E60E90416E3351D303A7CB8739B791CBD999FDC0CA37E` |
| Historical reads | Two independent full reads (`K4-03_factory_1.bin`, `K4-03_factory_2.bin`) matched the same size/hash |
| Restore note | `restore.txt` in the private directory |
| Restore tested? | **No** — the restore command is a plan, not a verified operation |

The private directory also contains `K4-03_FACTORY_VERIFIED.sha256.txt` and `restore.txt`. They are not committed because they contain the private path/user context.

### Content check

A read-only inspection of the verified image found the saved Wi-Fi configuration in the SDK parameter region:

- the known SSID string is present at offset `0x3FD010` (and duplicated at `0x3FE010`), which is the SDK Wi-Fi config area, not the application image;
- a credential-like field follows in the same structure; its exact encoding was not decoded, and no secret value is reproduced here;
- the rest of the last 16 KiB contains SDK/RF data, not just application code.

So the backup is **not** firmware-only. Treat the whole 4 MiB image as containing user settings, even though the password encoding was not reverse-engineered.

## 2. Repository policy

- The raw image stays in the private directory and in whatever offline backup the maintainer chooses.
- It is **not** copied into the repository; there is no `archive/` directory or Git-tracked binary.
- Only this manifest, the size/hash and the restore procedure are committed.
- If the repository is ever made private and the maintainer explicitly accepts the credential exposure, the raw image could be committed separately; that is not the current policy.

The maintainer will handle the manual backup; this page does not claim that a second copy exists.

## 3. Restore command (plan only)

Do not run this while the clock is working. It writes the complete private image from `0x000000`:

```powershell
py -m esptool --chip esp8266 --port COM3 --baud 115200 `
  --before no-reset --after no-reset `
  write-flash 0x000000 `
  <private-backup-dir>\K4-03_FACTORY_VERIFIED.bin
```

Before running:

1. Re-check the SHA-256 and size.
2. Confirm the unit is the same K4-03 (do not use the upstream K2-02 image).
3. Confirm GPIO0 is low and the clock was repowered into the bootloader.
4. Confirm `COM3` is not held by a serial monitor.
5. Obtain explicit approval; a restore has not been tested.

After writing, verify the flash, power off, remove GPIO0 from GND, power on, and check the factory display, Wi-Fi and web page.

## 4. Why the raw image is not in Git

The full flash contains the saved Wi-Fi configuration and unit-specific data. The repository is public. Committing it would expose private network settings and create a permanent Git-history copy that is difficult to remove. The safe handling is:

- keep the verified raw image only in the private directory/offline backup;
- commit this manifest, the size/hash and the restore procedure;
- never attach the image to an issue, release or pull request.

## 5. Related records

- [K4-03 deployment](2026-07-23-k4-03-deployment.md)
- [K4-03 hardware preparation](2026-07-23-k4-03-hardware-preparation.md)
- [Factory firmware](../modules/factory-firmware/README.md)
- [Deployment runbook](../modules/deployment/README.md)
