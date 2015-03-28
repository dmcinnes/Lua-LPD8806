data_pin  = 4
clock_pin = 6

gpio.mode(data_pin,  gpio.OUTPUT)
gpio.mode(clock_pin, gpio.OUTPUT)

led_count  = 16
byte_count = led_count * 3

leds = {}
for i=0, byte_count do
  -- highest most bit must be 1
  leds[i] = 0x80
end

function begin()
  -- send those zero bytes to clear the strip's data
  gpio.write(data_pin, gpio.LOW)

  count = math.floor(((byte_count+31)/32)*8)
  for i=0, count do
    gpio.write(clock_pin, gpio.HIGH)
    gpio.write(clock_pin, gpio.LOW)
  end
end

function setPixelColor(num, r, g, b)
  -- strip color order is GBR for some strange reason
  -- ORing so higest most bit is still 1
  leds[num]   = bit.bor(g, 0x80)
  leds[num+1] = bit.bor(b, 0x80)
  leds[num+2] = bit.bor(r, 0x80)
end

function show()
  -- iterate over led color value
  for i=0, byte_count do
    i = i - 1
    byte = leds[i]

    -- iterate over every bit
    bit = 0x80
    while bit >= 0x0 do
      if bit.band(bit, byte) == 0x0 then
        gpio.write(data_pin, gpio.LOW)
      else
        gpio.write(data_pin, gpio.HIGH)
      end

      gpio.write(clock_pin, gpio.HIGH)
      gpio.write(clock_pin, gpio.LOW)

      -- shift to next bit
      bit.rshift(bit)
    end
  end
end
