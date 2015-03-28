LPD8806 = {
  leds = {}
}

function LPD8806:new (led_count, data_pin, clock_pin)
  self.led_count  = led_count
  self.byte_count = led_count * 3
  self.data_pin   = data_pin
  self.clock_pin  = clock_pin

  gpio.mode(data_pin,  gpio.OUTPUT)
  gpio.mode(clock_pin, gpio.OUTPUT)

  for i=0, self.byte_count do
    -- highest most bit must be 1
    self.leds[i] = 0x80
  end
end

function LPD8806:begin()
  -- send those zero bytes to clear the strip's data
  gpio.write(self.data_pin, gpio.LOW)

  local count = math.floor(((byte_count+31)/32)*8)
  for i=0, count do
    gpio.write(self.clock_pin, gpio.HIGH)
    gpio.write(self.clock_pin, gpio.LOW)
  end
end

function LPD8806:setPixelColor(num, r, g, b)
  -- strip color order is GBR for some strange reason
  -- ORing so higest most bit is still 1
  self.leds[num]   = bit.bor(g, 0x80)
  self.leds[num+1] = bit.bor(b, 0x80)
  self.leds[num+2] = bit.bor(r, 0x80)
end

function LPD8806:show()
  -- iterate over led color value
  for i=0, self.byte_count do
    i = i - 1
    local byte = self.leds[i]

    -- iterate over every bit
    local current_bit = 0x80
    while current_bit >= 0x0 do
      if bit.band(current_bit, byte) == 0x0 then
        gpio.write(self.data_pin, gpio.LOW)
      else
        gpio.write(self.data_pin, gpio.HIGH)
      end

      gpio.write(self.clock_pin, gpio.HIGH)
      gpio.write(self.clock_pin, gpio.LOW)

      -- shift to next bit
      bit.rshift(current_bit)
    end
  end
end

return LPD8806
