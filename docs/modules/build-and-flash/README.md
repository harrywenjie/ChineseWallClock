# Build, Images and Flashing

This page is the build/flash contract for the current source. It records the inherited upstream environment, the verified fork build, image forms and the flashing paths. Deployment procedure is in [deployment](../deployment/README.md); hardware wiring is in [hardware](../hardware/README.md).

## 1. Original environment

The upstream README records:

- Ubuntu 22.04.4 LTS (jammy)
- Arduino IDE 2.3.2
- Wemos D1 mini as the development/test board

The fork's verified build (2026-07-23 and 2026-11-08) used:

- Windows 11
- Arduino CLI **0.35.3**
- ESP8266 core **3.1.2**
- Libraries from `libraries/libraries.zip`, extracted to a local libraries folder

The target FQBN is `esp8266:esp8266:d1_mini`. The physical clock uses an ESP-12F module; the D1 mini target is the compatible development board used by the original author.

## 2. Libraries

`libraries/libraries.zip` is the author's pinned library snapshot (12,334,448 bytes, 18 libraries). It is a backup, not a package manifest. Extract it to a libraries folder and pass that folder to the build; do not install “latest” versions over it.

Libraries actually used by the verified build:

| Library | Version | Source |
|---|---|---|
| WiFiManager | 2.0.17 | bundle |
| ArduinoJson | 7.0.4 | bundle |
| SimpleSyslog | 0.1.1 | bundle |
| AceWire | 0.4.1 | bundle |
| AceTimeClock | 1.3.0 | bundle |
| AceTime | 2.3.1 | bundle |
| AceCommon | 1.6.2 | bundle |
| AceSorting | 1.0.0 | bundle |
| ESP8266WiFi, ESP8266WebServer, DNSServer, LittleFS, ArduinoOTA, Wire, ESP8266mDNS | core 3.1.2 | ESP8266 platform |

The zip also contains libraries not used by this sketch (for example Timezone, ESP32httpUpdate, ESP-WiFiSettings). They are part of the author's backup; they are not required for a minimal build. See [libraries/README.md](../../../libraries/README.md) for the author's note.

## 3. Arduino IDE

1. Install Arduino IDE 2.3.2 (or a later 2.x) and the ESP8266 board package **3.1.2**.
2. Add `https://arduino.esp8266.com/stable/package_esp8266com_index.json` to Additional Boards Manager URLs.
3. Extract `libraries/libraries.zip` into your Arduino libraries folder (or use a sketchbook-local `libraries` folder).
4. Open `ChineseWallClock.ino`.
5. Select **Wemos D1 mini** (`esp8266:esp8266:d1_mini`), the correct port, 4 MB flash settings and the serial upload speed.
6. Verify/compile, then upload over serial or use the Arduino IDE network port for OTA.

The original author's screenshots of the web UI are in `docs/images/`; they are reference media, not build instructions.

<a id="arduino-cli"></a>

## 4. Arduino CLI

Install the ESP8266 core and extract the libraries once:

```text
arduino-cli core install esp8266:esp8266@3.1.2
arduino-cli config add board_manager.additional_urls https://arduino.esp8266.com/stable/package_esp8266com_index.json
```

Build from the repository root (the sketch is the directory):

```text
arduino-cli compile \
  --fqbn esp8266:esp8266:d1_mini \
  --libraries <path-to-extracted-libraries> \
  --build-path temp/build/verify \
  --output-dir temp/artifacts/verify \
  .
```

The verified Windows command (2026-11-08) is recorded verbatim in [the local build evidence](../../evidence/2026-11-08-local-build.md). It used a local `temp/arduino-cli.yaml`, `temp/arduino-data`, `temp/bundled/libraries` and `temp/build/docs-verify`; those paths are workspace-local and are not committed.

### Output and size

The successful build reports:

- RAM: 37,404 / 80,192 bytes (46 %)
- IRAM: 62,551 / 65,536 bytes (**95 %**)
- Flash: 443,980 / 1,048,576 bytes (42 %)
- Full image: **485,280 bytes**
- 14 `-Wwrite-strings` warnings, no errors

IRAM is the tight resource. Re-run the size report after every change; a small feature can hit the IRAM limit before flash is full.

## 5. Image forms and offsets

There are two related files:

| Form | Starts with | Size in the verified build | Intended offset | Source |
|---|---|---|---|---|
| Full Arduino image (`ChineseWallClock.ino.bin`) | `e9 02 02 40` header at 0x0000 | 485,280 bytes | `0x0000` | Normal Arduino/`elf2bin` output; also the form in `releases/` |
| App-only image (`app-at-0x1000.bin`) | `e9 05 02 40` header at 0x0000 | 481,184 bytes | `0x1000` if the bootloader is already present | Bytes `0x1000..end` of the full image |

Do not mix the two. A full image written at `0x1000` or an app-only image written at `0x0000` will not boot. Always record the exact file, hash and offset in the deployment record. The release binaries in `releases/` are full images; the fork's temp evidence contains an extracted app-only image for comparison.

## 6. Flashing paths

- **Serial (recommended for recovery):** connect a 3.3 V USB-TTL adapter to the 6-pin header, enter ESP8266 boot mode (typically `FLASH` low + pulse `RST`; verify on the board), and use the flash tool with the full image at `0x0000` or the app-only image at `0x1000`. Capture the complete serial log at 115200.
- **Arduino OTA:** with `ENABLE_OTA` compiled in, the device appears as a network port; the password is the AP name (`halclock<chipid>`). The device must already be on the same network. OTA progress feeds the watchdog.
- **Web UI firmware upload:** reported broken in the upstream README. Do not use it as a deployment path until it is reproduced and fixed.

The factory firmware is a **full-flash-style dump** (partial: 4,000,000 bytes), not an Arduino app image; restoring it is a different operation. See [factory firmware](../factory-firmware/README.md).

## 7. Reproducibility findings

- The current source is code-identical to v1.1 (`git diff 7d18e68..HEAD` changes no `.ino`, `.cpp` or `.h`), but the verified build is **485,280 bytes**, while the v1.1 release is **485,248 bytes**.
- All 2026-07-23 variants (`default`, `repro2`, `ide232-cli`, `canonical1`, `canonical2`) produced 485,280-byte full images. The 32-byte difference from v1.1 is **UNKNOWN**; possible causes include core/library patch versions or build flags.
- Build-path content/length can change the image hash while the size stays the same. Compare hashes only for the same path and toolchain; otherwise compare size, memory report and observed behaviour.
- The prior session tried Arduino IDE 2.3.2 options with Arduino CLI 0.35.3; 1.5.1 was downloaded but not used. No variant matched the release byte-for-byte. See [2026-07-23 fork build](../../evidence/2026-07-23-fork-build/README.md).

## 8. Common failures

| Symptom | Likely cause | Check |
|---|---|---|
| `WiFiManager.h: No such file` | Libraries folder not passed or zip not extracted | `--libraries` path contains `WiFiManager/library.properties` |
| Wrong board/core errors | ESP8266 core not 3.1.2 | `arduino-cli core list` |
| Image flashes but does not boot | Wrong image form/offset | Full at `0x0000`, app-only at `0x1000`; record hash |
| Cannot enter boot mode | Header orientation or `FLASH`/`RST` wiring | Photo, schematic, continuity; 3.3 V levels |
| OTA port missing | Device not on WiFi, OTA disabled, or wrong password | Serial log, `ENABLE_OTA`, AP name |
| Web upload fails | Known upstream defect | Use serial or OTA; do not retry blindly |
| IRAM overflow after a change | 95 % IRAM already used | Size report; reduce code or move data to flash |
