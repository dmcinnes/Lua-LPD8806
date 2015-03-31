LPD8806 = require('LPD8806')

lpd = LPD8806.new(16, 3, 4)
lpd:show()

function lpd_color(r, g, b)
  for i = 0, 15 do
    lpd:setPixelColor(i, r, g, b)
  end
  lpd:show()
end

function lpd_fade()
  local n = 0
  local dir = 0

  tmr.alarm(0, 100, 1, function()
    n = n + dir
    if n > 10 then
      dir = -1
    elseif n < 1 then
      dir = 1
    end
    lpd_color(0, 0, n)
  end)
end

function lpd_cylon()
  local n = 0
  local dir = 0

  tmr.alarm(0, 100, 1, function()
    for i = 0, 15 do
      if i == n then
        lpd:setPixelColor(i, 1, 0, 0)
      else
        lpd:setPixelColor(i, 0, 1, 1)
      end
    end
    n = n + dir
    if n >= 15 then
      dir = -1
    elseif n <= 0 then
      dir = 1
    end
    lpd:show()
  end)
end

function lpd_stop()
  tmr.stop(0)
end
