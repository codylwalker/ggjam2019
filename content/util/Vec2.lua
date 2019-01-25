import 'util'

local Vec2 = class ('Vec2')
function Vec2:init (x, y)   self:set_xy (x, y) end
function Vec2.new_from (v)  return Vec2.new (v[1], v[2]) end

function Vec2.get:x() return self[1] end
function Vec2.get:y() return self[2] end
function Vec2.set:x(x) self[1] = x end
function Vec2.set:y(y) self[2] = y end

function Vec2.metatable.__eq  (a, b)  return a[1] == b[1] and a[2] == b[2] end
function Vec2.metatable.__add (a, b)  return Vec2.new (v2.add (a[1], a[2], b[1], b[2])) end
function Vec2.metatable.__sub (a, b)  return Vec2.new (v2.sub (a[1], a[2], b[1], b[2])) end
function Vec2.metatable.__unm (v)     return Vec2.new (-v[1], -v[2]) end
function Vec2.metatable.__mul (a, b)
  if getmetatable (a) == Vec2.metatable then
    return Vec2.new (v2.mul (a[1], a[2], b))
  else
    return Vec2.new (v2.mul (b[1], b[2], a))
  end
end
function Vec2.metatable.__div (a, b) return Vec2.new (v2.div (a[1], a[2], b)) end
function Vec2.metatable.__tostring (v) return '(' .. v[1] .. ', ' .. v[2] .. ')' end
function Vec2:dot (v) return v2.dot (self[1], self[2], v[1], v[2]) end
function Vec2:project (v) return Vec2.new (v2.project (self[1], self[2], v[1], v[2])) end
function Vec2:magnitude () return v2.magnitude (self[1], self[2]) end
function Vec2:normalized (a) return Vec2.new (v2.normalized (self[1], self[2])) end

function Vec2:within_distance (b, distance)
  local difference = self - b
  return v2.magnitude (difference[1], difference[2]) < distance
end

function Vec2:get_xy () return self[1], self[2] end

function Vec2:set_from (v) self[1], self[2] = v[1], v[2] end
function Vec2:set_xy (x, y) self[1], self[2] = x, y end
function Vec2:do_add (v) self[1], self[2] = v2.add (self[1], self[2], v[1], v[2]) end
function Vec2:do_add_amount (v, s) self[1], self[2] = v2.add (self[1], self[2], v[1] * s, v[2] * s) end
function Vec2:do_sub (v) self[1], self[2] = v2.sub (self[1], self[2], v[1], v[2]) end
function Vec2:do_mul (s) self[1], self[2] = v2.mul (self[1], self[2], s) end
function Vec2:do_div (s) self[1], self[2] = v2.div (self[1], self[2], s) end
function Vec2:do_rotate (a) self[1], self[2] = v2.rotate (self[1], self[2], a) end
function Vec2:do_normalize (a) self[1], self[2] = v2.normalized (self[1], self[2]) end
function Vec2:get_heading () return math.atan2(self[2], self[1]) end


function Vec2:is_zero (v) return self[1] == 0 and self[2] == 0 end

function Vec2:is_small () return v2.magnitude (self.x, self.y) <= 0.00001 end

return Vec2
