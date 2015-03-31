local LPD8806 = {}
LPD8806.__index = LPD8806

do
  local HIGH   = gpio.HIGH
  local LOW    = gpio.LOW
  local write  = gpio.write
  local isset  = bit.isset
  local bor    = bit.bor

  function LPD8806.new(led_count, data_pin, clock_pin)
    local self = setmetatable({}, LPD8806)
    self.leds       = {}
    self.led_count  = led_count
    self.data_pin   = data_pin
    self.clock_pin  = clock_pin

    self:setup()

    return self
  end

  function LPD8806.setup(self)
    -- set pin modes
    gpio.mode(self.data_pin,  gpio.OUTPUT, gpio.PULLUP)
    gpio.mode(self.clock_pin, gpio.OUTPUT, gpio.PULLUP)
    write(self.data_pin, HIGH)
    write(self.clock_pin, HIGH)

    local led_byte_count = self.led_count * 3;

    for i=0, led_byte_count-1 do
      -- highest most bit must be 1
      self.leds[i] = 0x80
    end

    -- one byte per group of 32 leds
    local latch_bytes = math.floor((self.led_count + 31) / 32);

    -- add latch to end of our array
    for i=0, latch_bytes-1 do
      self.leds[led_byte_count + i] = 0x00
    end

    self.byte_count = led_byte_count + latch_bytes
    self.latch_byte_count = latch_bytes

    self:resetCursor()
  end

  function LPD8806.resetCursor(self)
    -- send those zero bytes to clear the strip's data
    write(self.data_pin, LOW)

    local count = self.latch_byte_count * 8
    local clk = self.clock_pin
    for i=0, count do
      write(clk, HIGH)
      write(clk, LOW)
    end
  end

  function LPD8806.setPixelColor(self, num, r, g, b)
    -- strip color order is GRB for some strange reason
    -- ORing so higest most bit is still 1
    if num >= 0 and num < self.led_count then
      local leds = self.leds
      local start = num * 3
      leds[start]   = bor(g, 0x80)
      leds[start+1] = bor(r, 0x80)
      leds[start+2] = bor(b, 0x80)
    end
  end

  function LPD8806.show(self)
    -- iterate over led color value
    -- local start = tmr.now()
    local byte
    local count     = self.byte_count
    local leds      = self.leds
    local data_pin  = self.data_pin
    local clock_pin = self.clock_pin

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

    -- print(tmr.now() - start)
  end

end

return LPD8806
