import 'util'

local colorUtil  = {}

function colorUtil.hsv_to_rgb (h, s, v)
  local c = v * s
  local hh = h * 6 % 6
  local x = c * (1 - math.abs (hh % 2 - 1))
  local r, g, b
  if hh <= 1 then
    r, g, b = c, x, 0
  elseif hh <= 2 then
    r, g, b = x, c, 0
  elseif hh <= 3 then
    r, g, b = 0, c, x
  elseif hh <= 4 then
    r, g, b = 0, x, c
  elseif hh <= 5 then
    r, g, b = x, 0, c
  else
    r, g, b = c, 0, x
  end
  local m = v - c
  r, g, b = r + m, g + m, b + m
  return r, g, b
end

function colorUtil.create(r, g, b, a)
  r = r or 0
  g = g or 0
  b = b or 0
  a = a or 1
  return {r = r, g = g, b = b, a = a}
end

function colorUtil.lerp_colors(color1, color2, ratio)
  local r = help.lerp(color1.r, color2.r, ratio)
  local g = help.lerp(color1.g, color2.g, ratio)
  local b = help.lerp(color1.b, color2.b, ratio)
  return colorUtil.create(r, g, b)
end

return colorUtil