# Firmware Overview

The firmware is a single Arduino sketch plus four small modules. This page is the reading map and cross-cutting contract; change-specific detail is in the linked topic pages.

## 1. Source map

| File | Role | Read when |
|---|---|---|
| `ChineseWallClock.ino` | `setup()`/`loop()`, config load/save, WiFiManager menu, OTA, reset logging, watchdog | Changing boot, portal, OTA or lifecycle |
| `myConfig.h`, `myConfig.cpp` | `Config` struct, defaults, shift-register pins, AP name/password | Changing a setting, pin or identity |
| `myDisplay.h`, `myDisplay.cpp` | Shift-register output, digits, brightness, 500 ms scheduler | Changing what the display shows |
| `myTime.h`, `myTime.cpp` | AceTime NTP + DS3231, timezone/DST conversion | Changing time sources or zones |
| `myLogging.h`, `myLogging.cpp` | Serial and optional syslog output | Adding or changing log output |

## 2. Boot and loop

`setup()`:

1. `Serial.begin(115200)`, log `Booting`.
2. Load `/halclock.conf` from LittleFS; missing file loads defaults.
3. Log the effective configuration.
4. Initialise the display and show `2020` while the clock is not ready.
5. Initialise `NTP + DS3231` via AceTime's `SystemClockLoop`.
6. Build the WiFiManager parameter menu, then connect or start the non-blocking portal.
7. Start ArduinoOTA when `ENABLE_OTA` is defined in `myConfig.h`.
8. Log the reset reason; disable the watchdog, `delay(3000)`, enable `WDTO_8S`.

`loop()` calls `wm.process()`, the time loop, the 500 ms display scheduler, `ArduinoOTA.handle()` when enabled, and `wdt_reset()`.

## 3. Implemented behaviour

- **Configuration UI:** WiFiManager portal with device name, NTP server, timezone, syslog server, brightness and four checkboxes (second blinking, clever numbering, leading zeros, automatic brightness).
- **Time:** NTP is the reference source; the DS3231 is the backup. Timezones and DST come from AceTime's `zonedbx` database using the configured IANA name.
- **Display:** hours and minutes on four digits; optional blinking second LEDs; optional leading zeros; “clever” glyph for a leading `1`; manual or automatic brightness.
- **Network:** AP/hostname `halclock` + uppercase chip ID; AP password `password`; hostname set to the same value; WiFiManager retries five times; portal remains available after a successful connection.
- **OTA:** Arduino IDE network upload, password set to the AP name; `ENABLE_OTA` controls compilation.
- **Logging:** serial at 115200 and optional UDP syslog at facility `LOCAL7`.
- **Watchdog:** 8 s, reset in the main loop and during OTA progress.

Open product items (timezone dropdown, web-UI password, MQTT, web-UI firmware upload) are tracked only in `docs/DEVELOPMENT.md` §5.

## 4. Cross-cutting invariants

- **One configuration object.** `Config config` is global; load happens before any consumer, save happens only from the portal callback and ends in `wm.reboot()`.
- **Display cadence.** `syncDisplayScheduler()` refreshes every 500 ms; it reads the local time each time. Do not add a second display update loop.
- **Time source.** `NtpClock` is the reference and `DS3231Clock` the backup; consumers call `getLocalTime()` rather than reading NTP or the RTC directly.
- **Identity.** AP SSID, hostname and OTA password are derived from `getAPName()`; changing one changes the others.
- **Logging is global.** The first log call may create the syslog client; changing `syslog_server` requires a reboot (the save path does one).
- **Watchdog.** Blocking work over 8 s without `wdt_reset()` will reset the device.

<a id="known-implementation-notes"></a>

## 5. Known implementation notes

These are code-inspection findings, not hardware reproductions:

- `saveConfiguration()` does not write `clever`; on the next load the missing key falls back to `"true"`. Unchecking clever therefore probably does not survive a reboot. See [configuration defects](configuration.md#known-persistence-defects).
- A failed LittleFS mount or a JSON parse error logs but does not apply defaults; the global `Config` can remain zeroed. See [configuration defects](configuration.md#known-persistence-defects).
- `loadConfiguration()` copies `timezone` with `sizeof(config.ntp_server)`; both fields are 64 bytes today, so this is harmless but fragile.
- `saveConfiguration()` uses `StaticJsonDocument<256>` for four 64-byte strings plus keys; long values may be tight. Test with maximum-length values before adding fields.
- `printCurrentTime()` is called from every `getLocalTime()` but only computes and discards values; it is a debug leftover.
- `warningLog()` is implemented but unused.
- `logResetReason()` and several logging calls assign string literals to `char*`, producing `-Wwrite-strings` warnings. The build has 14 such warnings and no errors.
- `secondLedsOn` uses `millis() % 1000`, so the blink phase is relative to boot, not the RTC second.
- `dsClock.setup()` and `systemClock->setup()` return values are not checked; a missing RTC is not explicitly reported.

## 6. Reading map

| Task | Next page |
|---|---|
| Defaults, JSON, web form, WiFi, OTA | [configuration](configuration.md) |
| Digits, brightness, leading zeros, clever `1`, second LEDs | [display](display.md) |
| NTP, DS3231, timezone/DST | [time](time.md) |
| Serial/syslog format | [logging](logging.md) |
| Build/flash/deploy | [build and flash](../build-and-flash/README.md), [deployment](../deployment/README.md) |

<a id="open-product-items"></a>

## 7. Open product items

The upstream README still lists a timezone drop-down, a password-protected web UI, MQTT and a broken web-UI firmware upload. The status and next-step conditions are maintained only in `docs/DEVELOPMENT.md` §5; this page does not duplicate or close them.
