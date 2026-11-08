# Time, NTP and RTC

This page covers time acquisition, the DS3231 backup and timezone/DST conversion. The source of truth is `myTime.cpp`; the RTC hardware is described in [hardware](../hardware/README.md).

## 1. Stack

The firmware uses [AceTime](https://github.com/bxparks/AceTime) and `AceTimeClock`:

- `NtpClock ntpClock` — reference clock, configured with `config.ntp_server`.
- `DS3231Clock<WireInterface> dsClock` — battery-backed backup on I2C.
- `SystemClockLoop systemClock` — combines the reference and backup.
- `ExtendedZoneManager` with the `zonedbx` zone/link registry and a 3-entry `ExtendedZoneProcessorCache` — converts epoch seconds to local time using `config.timezone`.

`Wire.begin()` uses the ESP8266 default I2C pins (GPIO4/5 unless the schematic says otherwise). `DS3231Clock::setup()` and `systemClock->setup()` are called without checking their return values.

## 2. Setup and loop

`syncTimeSetup()`:

1. Placement-new `NtpClock(config.ntp_server)`.
2. Allocate `SystemClockLoop(&ntpClock, &dsClock)`.
3. `Wire.begin()` and `wireInterface.begin()`.
4. `dsClock.setup()`.
5. `ntpClock.setup()`; logs “NTP setup OK” or an error.
6. `systemClock->setup()`.

`syncTimeLoop()` calls `systemClock->loop()` on every main-loop iteration. The display calls `getLocalTime()` twice per second.

`getLocalTime()`:

1. `systemClock->getNow()` returns epoch seconds.
2. `manager.createForZoneName(config.timezone)` creates a `TimeZone`.
3. `ZonedDateTime::forEpochSeconds(...)` converts to local time.
4. Copies year/month/day/hour/minute/second into the firmware `Time` struct.
5. Calls `printCurrentTime()` — a debug leftover that computes values and prints nothing.

## 3. Timezone and DST

- `config.timezone` is an IANA name such as `Europe/Budapest`; the full `zonedbx` registry is compiled in.
- DST is automatic from the timezone rules; there is no manual offset or DST switch.
- The string is **not validated**. An unknown name is likely treated as an unknown/UTC zone by AceTime; test any new zone on hardware before relying on it.
- The timezone lookup is repeated on every `getLocalTime()` call; the 3-entry cache is shared, but this is still more work than caching the `TimeZone` for a stable configuration.
- Changing the timezone via the web UI saves the config and reboots; the new zone is used on the next boot.

## 4. Failure behaviour

- NTP unreachable: `ntpClock.setup()` logs an error; `SystemClockLoop` is expected to use the DS3231 backup. The exact fallback timing is library behaviour and is **not verified on hardware** in this workspace.
- DS3231 missing or battery dead: `dsClock.setup()` is not checked; the system may still run from NTP when the network is available, but the failure is not explicitly logged.
- Both unavailable: the system clock may remain unset; the display will show whatever epoch-derived time results. The UI does not expose a “time not set” state.
- Power loss: the DS3231 battery is intended to keep time; battery condition and drift are not measured here.

## 5. Test checklist

- Cold boot with NTP reachable: serial shows NTP setup OK; display reaches the correct local time.
- Cold boot with NTP blocked: serial shows the NTP error; display uses the DS3231 and keeps time.
- DST transition: the displayed local time changes at the configured zone's transition without a manual setting.
- Invalid timezone: observe the actual fallback and record it; do not assume.
- Power-cycle with the RTC battery installed: time is retained.
- Power-cycle with the battery removed: record how long the clock takes to recover and what the display shows meanwhile.
- Change timezone through the web UI: after reboot, the new local time and DST rules apply.

## 6. Related reading

- [Configuration](configuration.md) — `ntp_server`, `timezone`, save/reboot path.
- [Display](display.md) — how the time is rendered.
- [Logging](logging.md) — NTP/RTC error messages.
- [Hardware](../hardware/README.md) — DS3231 and I2C pins.
