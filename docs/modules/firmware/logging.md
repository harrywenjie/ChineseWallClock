# Logging and Syslog

This page covers the serial/syslog logging path. The source of truth is `myLogging.cpp`.

## 1. API

Four varargs helpers share one `logging()` implementation:

| Function | Severity | Typical use |
|---|---|---|
| `debugLog()` | `PRI_DEBUG` | Boot, config, filesystem, WiFi details |
| `infoLog()` | `PRI_INFO` | Lifecycle events, AP identity, OTA start/end |
| `warningLog()` | `PRI_WARNING` | **Unused** in the current source |
| `errorLog()` | `PRI_ERROR` | Filesystem, brightness clamp, WiFi/OTA errors |

Every message is formatted with `vasprintf()`, printed to Serial as `[LEVEL] message`, sent to syslog when configured, and freed. The dynamic allocation per message is normal for diagnostic logging but is a fragmentation risk if logging is added in a tight loop.

## 2. Serial

`Serial.begin(115200)` is called first in `setup()`. The first line is `[INFO] Booting`. The boot log then includes the effective configuration, AP name/password, NTP setup result, WiFi result, OTA status and reset reason. This is the primary diagnostic channel for a deployment; capture it before and after flashing.

## 3. Syslog

- Disabled when `strlen(config.syslog_server) <= 1`.
- On the first log call with a longer server string, a `SimpleSyslog` instance is created with:
  - hostname `getAPName()`;
  - application name `APPLICATION_NAME` (`HalClock`);
  - the configured server address.
- Messages use facility `FAC_LOCAL7` and the severity above.
- The client is global and lazy: changing `syslog_server` requires a reboot to recreate it. The web save path already reboots.
- The default server is a private LAN address defined in `myConfig.h`. With the default, the firmware will attempt syslog on the first log call even if no collector exists; UDP failures are not surfaced.
- The actual K4-03 deployment left `syslog_server` empty, which disables the remote client. The transport is UDP 514; use a trusted collector and keep the address private.
- Syslog is plain UDP, unauthenticated and unencrypted. Use it only on a trusted network.

## 4. Message conventions

- Prefix severity in brackets: `[INFO]`, `[DEBUG]`, `[WARNING]`, `[ERROR]`.
- Use `%s`, `%d` and `%.2f` formats supported by the ESP8266 `printf`; avoid `%zu`/`%llu` unless verified.
- Do not log credentials, WiFi passwords or full configuration dumps in new code. The existing save path echoes the JSON configuration to Serial, including the syslog address; treat captured logs as sensitive.
- `logResetReason()` maps ESP8266 reset reasons and logs a human-readable string.

## 5. Test checklist

- Serial at 115200 shows boot, config, AP identity and reset reason.
- With an empty syslog server, no syslog client is created.
- With a reachable collector, messages arrive with `LOCAL7` and the expected severity.
- With an unreachable collector, boot and display behaviour do not block.
- Changing the syslog server via the web UI takes effect after reboot.
