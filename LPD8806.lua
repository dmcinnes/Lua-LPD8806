local LPD8806 = {}
LPD8806.__index = LPD8806

function LPD8806.new(led_count, data_pin, clock_pin)
  local self = setmetatable({}, LPD8806)
  self.leds       = {}
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

  for i=0, self.byte_count-1 do
    -- highest most bit must be 1
    self.leds[i] = 0x80
  end

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
    local start = num * 3
    self.leds[start]   = bit.bor(g, 0x80)
    self.leds[start+1] = bit.bor(r, 0x80)
    self.leds[start+2] = bit.bor(b, 0x80)
  end
end

function LPD8806.show(self)
  -- iterate over led color value
  local start = tmr.now()
  local byte
  local count     = self.byte_count
  local leds      = self.leds
  local isset     = bit.isset
  local HIGH      = gpio.HIGH
  local LOW       = gpio.LOW
  local data_pin  = self.data_pin
  local clock_pin = self.clock_pin
  local write     = gpio.write

  for i=0, count-1 do
    byte = leds[i]

    -- iterate backwards over every bit
    for j=7, 0, -1 do
      if isset(byte, j) then
        write(data_pin, HIGH)
      else
        write(data_pin, LOW)
      end

      write(clock_pin, HIGH)
      write(clock_pin, LOW)
    end
  end

  print(tmr.now() - start)

  self:resetCursor()
end

return LPD8806
