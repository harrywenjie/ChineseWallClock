# Display and Brightness

This page covers the four-digit display, the shift-register protocol, digit mapping and brightness. The source of truth is `myDisplay.h` / `myDisplay.cpp`; the hardware reference is [hardware](../hardware/README.md).

## 1. Hardware path

Four **74HC595D** shift registers drive the segments. The ESP-12F writes one bit at a time and latches the result:

| Signal | GPIO | Purpose |
|---|---|---|
| `SR_SER` | 13 | Serial data into the shift-register chain |
| `SR_SRCLK` | 14 | Shift clock (SHCP) |
| `SR_RCLK` | 12 | Storage/latch clock (STCP) |
| `SR_OE` | 15 | Output enable, inverted; used for PWM brightness |

Segments are **active-low**: a `0` bit turns the related segment on. The original `docs/display/digits on display.ods` records the segment numbering and states “A segment is ON if related bit is ZERO.” The handwritten photo `docs/display/IMG20240320232149.jpg` shows the numbering used when the mapping was worked out: top 6, top-right 5, bottom-right 4, bottom 3, bottom-left 2, top-left 1, middle 0, plus a `sec` note.

`myDisplay.h` contains two 20-entry tables:

- `mapping[]` — the standard glyph for digits 0–9, plus single-segment, full-on, full-off and dash entries (`DIGIT_OFF` = 18, `DIGIT_DASH` = 19).
- `mappingClever[]` — identical to `mapping[]` except for digit `1`: it uses an alternate single-side glyph.

The tables are hardware-specific. Do not regenerate them from a generic seven-segment table without checking the physical wiring.

## 2. Output path

`sendByte(digit, second, leadingDigit, clever)`:

1. Selects `mapping[]` or `mappingClever[]` for a digit, or the dash for invalid input.
2. If this is a leading digit and `config.leading_zeros` is false, substitutes `DIGIT_OFF`.
3. If second LEDs are enabled, clears bit 7 of the byte.
4. Writes eight bits LSB-first with `storeBit()`.
5. `allDigitsToStorageRegisters()` pulses `SR_RCLK` to latch all four bytes.

`show(digit1, digit2, digit3, digit4, second, clever)` writes the four digits, latches, and calls `enableDisplay(true)`.

## 3. What is displayed

`updateDisplay()` runs every 500 ms:

1. `getLocalTime()` returns year/month/day/hour/minute/second.
2. Hour and minute are split into two digits each with `convert()`; values outside 0–99 become dashes.
3. `secondLedsOn` is always true when `config.second_blinking` is false; otherwise it is `(millis() % 1000) > 500`, i.e. a 500 ms on/off phase relative to boot, not the RTC second.
4. `show(hourHi, hourLo, minuteHi, minuteLo, secondLedsOn, config.clever)`.

Display format is `HH:MM`; there is no date, temperature or scrolling mode.

### Leading zeros

`leadingDigit` is true only for the first digit of the hour and the first digit of the minute. With `config.leading_zeros == false`, a zero in either position is blanked. The second digit of each pair is never blanked. This matches the upstream commit “leading zero: only on the first digit but the 3rd”.

### Clever `1`

`show()` computes:

- `doItSmart1 = clever && digit1 == 1 && digit2 != 1`
- `doItSmart2 = clever && digit3 == 1 && digit4 != 1`

The alternate glyph is used only for a leading `1` whose paired digit is not also `1`; the second digit of each pair always uses the standard glyph. If `config.clever` is false, both use the standard glyph.

### Second LEDs

When `second` is true, bit 7 of every digit byte is cleared. The board uses that bit for the two second LEDs associated with digits 3 and 4; the code applies the mask to all four bytes. With blinking enabled, the LEDs toggle every 500 ms.

## 4. Brightness

`enableDisplay(enabled)` chooses the PWM value:

- Manual: `255 - config.brightness`. Because `SR_OE` is inverted, a higher `config.brightness` gives a brighter display; `255` is brightest and `1` is dimmest.
- Automatic: `sensorBridghtness()` reads `A0`, divides by 4 and caps at `auto_brightness_minimum_light` (245). This value is written directly to `analogWrite()` and overrides the manual value. The light-sensor polarity depends on the board divider and is not documented here.
- Disabled: writes 255 (display off).

The function name `sensorBridghtness` contains a typo; it is internal and harmless. `config.brightness` is loaded without clamping, while the web form clamps saves to 1–255. A zero loaded from a corrupt file would produce `255 - 0 = 255`, i.e. off.

`displaySetup()` initialises the four pins, sets `SR_OE` high (off), and shows `2020` with the second LEDs on as a boot indication. The first 500 ms refresh replaces it with the current clock value; if the clock is not set, the display may show an unset/epoch-derived value.

## 5. Known quirks

- `displaySetup()` is the only place that writes a fixed boot pattern; there is no “time not set” indicator.
- `show()` calls `enableDisplay(true)` on every refresh; brightness PWM is re-applied every 500 ms.
- The scheduler is not aligned to the RTC second boundary; the blink phase is based on `millis()`.
- `convert()` rejects values outside 0–99, but the byte parameter in `sendByte()` makes the `< 0` check ineffective; invalid values become dashes by the `> 9` branch.
- The `mapping[]` tables and the ODS/photo are the authoritative wiring record; changing them requires a hardware check.

## 6. Test checklist

- All segments of each digit light correctly; no ghosting or shifted digits.
- `HH:MM` ordering matches the physical digit order.
- Leading-zero off blanks the hour tens and minute tens only; the ones digits keep zero.
- Clever `1` changes the leading glyph only when the paired digit is not `1`.
- Second LEDs are steady when blinking is off and toggle when it is on.
- Manual brightness 1, 128 and 255 gives dim, medium and bright; automatic brightness overrides it.
- Boot shows `2020` briefly, then the current time.
- Power-cycle with the RTC battery removed (NTP unavailable) shows the fallback behaviour documented in [time](time.md).
