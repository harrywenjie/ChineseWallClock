# 显示与亮度

本页覆盖四位数字显示、shift register 协议、数字 mapping 和亮度。源码事实以 `myDisplay.h` / `myDisplay.cpp` 为准；硬件参考见 [hardware](../hardware/README.md)。

## 1. 硬件路径

4 片 **74HC595D** shift register 驱动 segments。ESP-12F 逐 bit 写入再 latch：

| Signal | GPIO | 用途 |
|---|---|---|
| `SR_SER` | 13 | shift register chain 的 serial data |
| `SR_SRCLK` | 14 | shift clock（SHCP） |
| `SR_RCLK` | 12 | storage/latch clock（STCP） |
| `SR_OE` | 15 | output enable，inverted；用于 PWM brightness |

segments 是 **active-low**：`0` bit 点亮对应 segment。`docs/display/digits on display.ods` 记录 segment 编号并说明“A segment is ON if related bit is ZERO”。手写照片 `docs/display/IMG20240320232149.jpg` 记录了 reverse engineering 时的编号：top 6、top-right 5、bottom-right 4、bottom 3、bottom-left 2、top-left 1、middle 0，另有 `sec`。

`myDisplay.h` 有两张 20 项表：

- `mapping[]`：0–9 的标准 glyph，加 single-segment、full-on、full-off、dash（`DIGIT_OFF` = 18，`DIGIT_DASH` = 19）。
- `mappingClever[]`：除 digit `1` 外与 `mapping[]` 相同；`1` 用 alternate single-side glyph。

表是 board-specific。没有检查实际接线时，不要用通用 seven-segment 表重新生成。

## 2. 输出路径

`sendByte(digit, second, leadingDigit, clever)`：

1. 选 `mapping[]` 或 `mappingClever[]`；非法输入用 dash。
2. 如果是 leading digit 且 `config.leading_zeros` 为 false，换成 `DIGIT_OFF`。
3. 如果启用秒点，清掉 byte 的 bit 7。
4. 用 `storeBit()` LSB-first 写 8 bit。
5. `allDigitsToStorageRegisters()` 脉冲 `SR_RCLK`，latch 四个 byte。

`show(digit1, digit2, digit3, digit4, second, clever)` 写四个 digit，latch，然后 `enableDisplay(true)`。

## 3. 显示内容

`updateDisplay()` 每 500 ms 跑一次：

1. `getLocalTime()` 返回 year/month/day/hour/minute/second。
2. hour 和 minute 各用 `convert()` 拆成两位；超出 0–99 变成 dash。
3. `config.second_blinking` 为 false 时 `secondLedsOn` 恒 true；否则 `(millis() % 1000) > 500`，即相对 boot 的 500 ms on/off 相位，不是 RTC 秒。
4. `show(hourHi, hourLo, minuteHi, minuteLo, secondLedsOn, config.clever)`。

格式是 `HH:MM`；没有日期、温度或滚动模式。

### 前导零

`leadingDigit` 只对 hour 的第一位和 minute 的第一位为 true。`config.leading_zeros == false` 时，这两位中的 0 会被 blank；每对的第二位永远不 blank。这对应 upstream commit “leading zero: only on the first digit but the 3rd”。

### Clever `1`

`show()` 计算：

- `doItSmart1 = clever && digit1 == 1 && digit2 != 1`
- `doItSmart2 = clever && digit3 == 1 && digit4 != 1`

alternate glyph 只用于“paired digit 也不是 1”的 leading `1`；每对第二位始终 standard glyph。`config.clever` 为 false 时两者都用 standard glyph。

### 秒点 LED

`second` 为 true 时，每个 digit byte 的 bit 7 被清掉。板子把这个 bit 用于 digit 3/4 对应的两个秒点 LED；代码对四个 byte 都做 mask。开启 blink 时 LED 每 500 ms 切换。

## 4. 亮度

`enableDisplay(enabled)` 选 PWM 值：

- Manual：`255 - config.brightness`。`SR_OE` inverted，所以 `config.brightness` 越大越亮；`255` 最亮，`1` 最暗。
- Automatic：`sensorBridghtness()` 读 `A0`，除以 4，封顶 `auto_brightness_minimum_light`（245）。这个值直接写 `analogWrite()`，覆盖 manual。光敏 polarity 取决于板子分压，本文不推断。
- Disabled：写 255（关显示）。

函数名 `sensorBridghtness` 有拼写错误；内部使用，无害。`config.brightness` load 不 clamp，Web form save clamp 1–255。损坏文件中的 0 会得到 `255 - 0 = 255`，即全暗。

`displaySetup()` 初始化四个 pin，拉高 `SR_OE`（off），显示 `2020` 且秒点 LED 亮，作为 boot 提示。第一次 500 ms refresh 会替换成当前 clock 值；如果 clock 未设置，可能显示 epoch 派生值。

实际 K4-03 初次目视显示正常，但详细 segment/ghosting 测试未记录。自动亮度偏暗，maintainer 已改用固定 brightness；根因未确认。

## 5. 已知问题

- `displaySetup()` 是唯一固定 boot pattern；没有“time not set”提示。
- `show()` 每次 refresh 都调 `enableDisplay(true)`；brightness PWM 每 500 ms 重写。
- scheduler 不对齐 RTC 秒边界；blink 相位基于 `millis()`。
- `convert()` 拒绝 0–99 以外的值，但 `sendByte()` 的参数是 byte，`< 0` 分支无效；非法值由 `> 9` 分支变成 dash。
- K4-03：初次目视正常；自动亮度偏暗，已用固定亮度；详细 segment/ghosting 未记录。GPIO15/OE 可能在 reset 时短暂显示随机段。

## 6. 测试检查单

- 每个 digit 的所有 segment 正确点亮；没有 ghosting 或移位。
- `HH:MM` 顺序与物理 digit 顺序一致。
- leading-zero off 只 blank hour tens 和 minute tens；ones 位保留 0。
- clever `1` 只在 paired digit 不是 `1` 时改 leading glyph。
- 秒点 LED 在 blink off 时常亮，on 时切换。
- manual brightness 1、128、255 分别暗、中、亮；auto brightness 覆盖 manual。
- boot 短暂显示 `2020`，然后显示当前时间。
- 拔掉 RTC 电池、NTP 不可用时，显示 [time](time.md) 记录的 fallback 行为。
