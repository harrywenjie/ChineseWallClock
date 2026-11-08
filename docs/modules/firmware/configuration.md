# Configuration, Web UI, WiFi and OTA

This page is the contract for runtime settings and the configuration portal. The source of truth is `myConfig.h` / `ChineseWallClock.ino`; this page explains the intended behaviour and records known defects.

## 1. Configuration fields

| Field | Type | Default | JSON key | Web control | Notes |
|---|---|---|---|---|---|
| `syslog_server` | `char[64]` | private LAN address (see `myConfig.h`) | `syslog_server` | text | The default enables syslog; string length > 1 creates the client on the first log call |
| `device_name` | `char[64]` | `HalClock` | `device_name` | text | Used as the WiFiManager page title; the AP/hostname is derived separately from the chip ID |
| `ntp_server` | `char[64]` | `hu.pool.ntp.org` | `ntp_server` | text | Hostname or IP passed to AceTime `NtpClock` |
| `timezone` | `char[64]` | `Europe/Budapest` | `timezone` | text | Must be an AceTime `zonedbx` IANA name; not validated by the firmware |
| `leading_zeros` | `bool` | `true` | `leading_zeros` | checkbox | Suppresses the leading zero on the first digit of the hour and minute pairs |
| `clever` | `bool` | `true` | `clever` | checkbox | Uses the alternate `1` glyph for a leading `1`; **not written by `saveConfiguration()`** |
| `second_blinking` | `bool` | `false` | `second_blinking` | checkbox | Blinks the second LEDs every 500 ms |
| `brightness` | `byte` | `255` | `brightness` | number 0–255 | Manual brightness; web save clamps to 1–255, load does not clamp |
| `auto_brightness` | `bool` | `true` | `auto_brightness` | checkbox | Overrides manual brightness with the `A0` light-sensor value |

Defaults are in `myConfig.h`. `auto_brightness_minimum_light` is `245`; the display code treats it as the maximum PWM value, not a minimum light level, despite the name.

## 2. Persistence format

The file is LittleFS `/halclock.conf`. A normal save writes compact JSON; booleans are strings `"true"` / `"false"` and brightness is a string. This is the shape a save produces (default values):

```json
{"device_name":"HalClock","ntp_server":"hu.pool.ntp.org","timezone":"Europe/Budapest","syslog_server":"<syslog-host>","second_blinking":"false","leading_zeros":"true","auto_brightness":"true","brightness":"255"}
```

`<syslog-host>` stands for the private LAN default in `myConfig.h`; replace it with your collector when deploying.

`clever` is absent because of the defect described in §6. On load, a missing `clever` key falls back to the default `"true"`.

## 3. Load path

1. `LittleFS.begin()` mounts the filesystem.
2. If `/halclock.conf` exists, it is opened and parsed into `StaticJsonDocument<512>`.
3. Each field is copied with `| default`; boolean fields compare the stored string with `"true"`; brightness uses `atoi`.
4. If the file does not exist, all defaults are applied.
5. If the file exists but parsing fails, or if the filesystem does not mount, the code only logs; it does **not** apply defaults. The global `Config` can therefore remain zeroed (empty strings, false flags, brightness 0).

The timezone copy uses `sizeof(config.ntp_server)` rather than `sizeof(config.timezone)`. Both are 64 bytes today, so there is no overflow, but the expression is wrong and should be fixed when touched.

## 4. Save path

`saveParamsCallback()` copies the form values into `config`, clamps brightness into 1–255, calls `saveConfiguration()`, then `wm.reboot()`.

`saveConfiguration()`:

1. Mounts LittleFS.
2. Removes the old file (the library appends otherwise).
3. Opens a new file for writing.
4. Builds a `StaticJsonDocument<256>`, sets the fields except `clever`, converts brightness with `itoa`, serialises to the file, echoes the JSON to Serial and closes the file.
5. On file-create or write failure, logs an error and returns.

The 256-byte document is tight for four 64-byte strings plus keys and values. It works with the defaults and short user values; test with maximum-length values before adding another field.

## 5. Web UI and WiFiManager

The portal menu is `wifi`, `info`, `param`, `sep`, `restart`. `wm.setTitle(config.device_name)` supplies the page title; `wm.setHostname(getAPName())` sets the hostname. The form has nine fields in this order: device name, NTP server, timezone, syslog server, brightness, second blinking, clever, leading zeros, auto brightness.

Checkbox parameters are submitted as `"1"` and are compared with `"1"` in `saveParamsCallback()`; JSON uses `"true"` / `"false"`. Keep both conventions consistent when adding a field.

WiFi setup:

- AP/hostname: `halclock` + uppercase chip ID from `WIFI_getChipId()`.
- AP password: hard-coded `password`.
- `setConnectRetries(5)`, non-blocking portal, auto-reconnect enabled.
- On success, `wm.startWebPortal()` keeps the web UI available on the station network.
- On failure, the configuration AP remains available; `loop()` services it with `wm.process()`.

The README's claim that the AP turns off after configuration is a WiFiManager behaviour, not an explicit firmware action; verify it on the target unit before relying on it. mDNS resolution of the hostname is not verified; use the IP shown by the portal or serial log.

<a id="known-persistence-defects"></a>

## 6. Known persistence defects

These are code-inspection findings, not hardware reproductions:

- **`clever` is not saved.** The field is loaded and shown in the form, but `saveConfiguration()` never writes it. Unchecking clever and saving will likely revert to `true` after reboot.
- **No defaults on parse/mount failure.** The error paths log but leave the global config zeroed. A corrupt file can produce an empty device name, empty NTP/timezone/syslog strings, and brightness 0. The display may stay dark because manual brightness becomes `255 - 0`.
- **Loaded brightness is not clamped.** Web saves clamp to 1–255; a value written to the file by another method can wrap when assigned to `byte`.
- **The save document is small.** Four 64-byte strings plus JSON keys may exceed `StaticJsonDocument<256>` with long values.
- **The timezone copy uses the NTP field size.** Harmless while both are 64 bytes, but fragile.

## 7. OTA and security

- `ENABLE_OTA` is defined in `myConfig.h`; OTA code is compiled only when it is defined.
- `ArduinoOTA.setHostname(getAPName())` and `ArduinoOTA.setPassword(getAPName())`; the OTA password is therefore the discoverable AP name.
- OTA progress calls `wdt_reset()`; the 8 s watchdog therefore does not abort a normal upload.
- The web UI has no authentication. The AP password is hard-coded and the OTA password is predictable. Treat the device as a trusted-home-network appliance, not an internet-facing service.
- `saveConfiguration()` echoes the JSON, including the syslog server address, to serial. Do not capture serial logs from an untrusted location.

## 8. Change checklist

When adding or changing a configuration field:

1. Update `Config`, the default macros and `loadConfiguration()`.
2. Update `menuSetup()` and `saveParamsCallback()`.
3. Update `saveConfiguration()` and check the JSON document capacity.
4. Update this page and the entry's current snapshot if behaviour changes.
5. Test: fresh boot defaults, save, power-cycle persistence, maximum-length values, corrupt JSON, and the relevant display/network effect.

## 9. UI reference

These inherited upstream screenshots show the intended portal layout and a real deployment of the upstream firmware. They are reference media, not fork deployment evidence; values are examples, not defaults. Network identifiers are deliberately not transcribed.

- [Landing page](../../images/main_page.png) — title, hostname/IP, Configure WiFi / Info / Setup / Restart.
- [Setup page](../../images/setup_page.png) — the configuration fields and checkboxes.
- [WiFi page](../../images/wifi.png) — SSID/password form, scan and refresh.

## 10. Test checklist

- Fresh boot with no `/halclock.conf` shows the documented defaults.
- Each field survives save + reboot; specifically test `clever` and `leading_zeros`.
- A corrupt JSON file and a missing filesystem are recovered deliberately (currently a known defect).
- Brightness 0, 1, 255 and 256 behave as intended; auto brightness overrides manual.
- Invalid timezone falls back visibly or is rejected (not currently validated).
- AP SSID/password, portal title, station IP and OTA password match this page.
- Web-UI firmware upload is known broken; use serial or OTA until it is fixed and verified.
