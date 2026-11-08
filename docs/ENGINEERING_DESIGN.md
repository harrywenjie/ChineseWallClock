# Engineering Design Navigation

This is a map; contracts are in `docs/modules/` and qualifications in `docs/VALIDATION.md`.

## 1. System context

An ESP-12F drives four 74HC595D shift registers (four digits + second LEDs), reads a DS3231 over I2C and a light sensor on `A0`, and uses WiFi for NTP, the portal, OTA and syslog. Actual fork unit: K4-03; hardware: [hardware](modules/hardware/README.md).

## 2. Runtime flow

`setup()`: serial 115200 → load `/halclock.conf` → display init → NTP/RTC init → WiFiManager menu → connect or start portal → OTA (if `ENABLE_OTA`) → log reset reason → 3 s watchdog-off delay → 8 s watchdog.

`loop()`: `wm.process()` → `systemClock->loop()` → 500 ms display refresh → `ArduinoOTA.handle()` → `wdt_reset()`.

The display reads local time each refresh; the web UI only edits config, then saves and reboots.

## 3. Module map

| Source | Responsibility | Contract |
|---|---|---|
| `ChineseWallClock.ino` | Boot/loop, config, portal, OTA, reset log, watchdog | [firmware](modules/firmware/README.md) |
| `myConfig.*` | `Config`, defaults, pins, AP identity | [configuration](modules/firmware/configuration.md) |
| `myDisplay.*` | Shift registers, digits, brightness, scheduler | [display](modules/firmware/display.md) |
| `myTime.*` | AceTime NTP + DS3231 + timezone/DST | [time](modules/firmware/time.md) |
| `myLogging.*` | Serial + optional syslog | [logging](modules/firmware/logging.md) |

## 4. Cross-cutting contracts

- **Config:** LittleFS `/halclock.conf`; defaults in `myConfig.h`; load/save use different boolean spellings (`"true"` vs `"1"`); save reboots.
- **Time:** `NtpClock` reference + `DS3231Clock` backup in AceTime `SystemClockLoop`; timezone is a `zonedbx` IANA name; DST from the database.
- **Display:** LSB-first shift + latch; segments active-low; manual brightness inverted for `SR_OE`; auto brightness from `A0` overrides manual.
- **Identity:** AP/hostname `halclock` + chip ID; AP password `password`; OTA password = AP name; no web authentication.
- **Logging/watchdog:** serial always; syslog lazily created when configured, facility `LOCAL7`; 8 s watchdog reset by loop and OTA.

## 5. Design decisions and constraints

- Arduino/ESP8266 + WiFiManager: approachable, but large dependencies and limited testing.
- LittleFS + ArduinoJson: local config without a service; the save document is capacity-limited.
- AceTime + full timezone database: DST without a network lookup; costs code size and repeated zone lookups.
- `libraries/libraries.zip` pins the build; no automated tests, so the real loop is compile + a physical clock.
- Tracked tree is upstream work; fork build/deployment records stay in history/evidence and must not be merged into upstream history.

## 6. Reading map

| Change | Read |
|---|---|
| Web form, defaults, persistence, WiFi/OTA | [configuration](modules/firmware/configuration.md) |
| Digits, brightness, leading zeros, clever `1`, second LEDs | [display](modules/firmware/display.md) |
| NTP, DS3231, timezone/DST | [time](modules/firmware/time.md) |
| Log format, syslog | [logging](modules/firmware/logging.md) |
| Build, libraries, image offsets, flashing | [build and flash](modules/build-and-flash/README.md) |
| End-to-end deployment | [deployment](modules/deployment/README.md) |
| Factory image or original UI | [factory firmware](modules/factory-firmware/README.md) |
| Schematic, pinout, datasheets | [hardware](modules/hardware/README.md) |

## 7. Known design debt

- No web authentication; hard-coded AP password; OTA password is the AP name.
- `clever` is not serialised; corrupt/missing config may not fall back to defaults.
- Timezone lookup repeats every refresh; `printCurrentTime()` is a no-op; `warningLog()` is unused; string-literal warnings remain.
- Web-UI firmware upload is reported broken upstream; serial/OTA are known paths, neither verified in this fork.

Open items: `docs/DEVELOPMENT.md` §5. This page does not authorise fixes.
