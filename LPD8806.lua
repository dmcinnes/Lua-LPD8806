local LPD8806 = {}
LPD8806.__index = LPD8806

function LPD8806.new(led_count, data_pin, clock_pin)
  local self = setmetatable({}, LPD8806)
  self.led_count  = led_count
  self.byte_count = led_count * 3
  self.data_pin   = data_pin
  self.clock_pin  = clock_pin

  self:setup()

  return self
end

function LPD8806.setup(self)
  -- set pin modes
  gpio.mode(self.data_pin,  gpio.OUTPUT, gpio.PULLUP)
  gpio.mode(self.clock_pin, gpio.OUTPUT, gpio.PULLUP)
  gpio.write(self.data_pin, gpio.HIGH)
  gpio.write(self.clock_pin, gpio.HIGH)

  self.leds = string.rep(string.char(0x80), self.byte_count)

  self:resetCursor()
end

function LPD8806.resetCursor(self)
  -- send those zero bytes to clear the strip's data
  gpio.write(self.data_pin, gpio.LOW)

  -- one byte per group of 32 leds
  local count = math.floor((self.led_count+31)/32)*8
  for i=0, count do
    gpio.write(self.clock_pin, gpio.HIGH)
    gpio.write(self.clock_pin, gpio.LOW)
  end
end

function LPD8806.setPixelColor(self, num, r, g, b)
  -- strip color order is GRB for some strange reason
  -- ORing so higest most bit is still 1
  if num >= 0 and num < self.led_count then
    local str       = self.leds
    -- string indexes start at 1
    local start     = (num * 3) + 1
    local new_pixel = string.char(bit.bor(g, 0x80), bit.bor(r, 0x80), bit.bor(b, 0x80))
    self.leds = str:sub(1, start-1) .. new_pixel .. str:sub(start+3)
  end
end

function LPD8806.show(self)
  local start = tmr.now()
  -- iterate over led color value
  local count = self.byte_count
  local leds  = self.leds
  for i=1, count do
    local byte = leds:byte(i)

    -- iterate over every bit
    local current_bit = 0x80
    while current_bit > 0x00 do
      if bit.band(current_bit, byte) > 0x00 then
        gpio.write(self.data_pin, gpio.HIGH)
      else
        gpio.write(self.data_pin, gpio.LOW)
      end

      gpio.write(self.clock_pin, gpio.HIGH)
      gpio.write(self.clock_pin, gpio.LOW)

      -- shift to next bit
      current_bit = bit.rshift(current_bit, 1)
    end
  end

  print(tmr.now() - start)
  self:resetCursor()
end

return LPD8806
