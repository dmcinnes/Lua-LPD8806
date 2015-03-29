Lua LPD8806
===========

Port of [Adafruit's LPD8806 library](https://github.com/adafruit/LPD8806) to Lua for use on the awesome [ESP8266 Wifi module](http://hackaday.com/2014/08/26/new-chip-alert-the-esp8266-wifi-module-its-5/) running the [Lua-based nodemcu-firmware](https://github.com/nodemcu/nodemcu-firmware).

Usage:

```lua
LPD8806 = require('LPD8806')
-- number of pixels, data pin and clock pin.
lpd = LPD8806.new(32, 3, 4)
lpd.setPixelColor(0, 128, 0, 0)
lpd.show()
```

See https://github.com/nodemcu/nodemcu-firmware#gpio-new-table--build-20141219-and-later for pin numbers, they're not what you expect.
