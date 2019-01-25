local v2 = {}

function v2.add (ax, ay, bx, by) return ax + bx, ay + by end
function v2.sub (ax, ay, bx, by) return ax - bx, ay - by end
function v2.dot (ax, ay, bx, by) return ax * bx + ay * by end
function v2.mul (ax, ay, b)      return ax * b, ay * b end
function v2.div (ax, ay, b)      return v2.mul (ax, ay, 1/b) end
function v2.magnitude (x, y)     return math.sqrt (x*x + y*y) end

function v2.normalized (x, y)
  local length = v2.magnitude (x, y)
  if length == 0 then
    return 0, 0
  else
    return x / length, y / length
  end
end

function v2.rotate (vx, vy, a)
  local cos_a = math.cos (a)
  local sin_a = math.sin (a)
  return cos_a * vx - sin_a * vy, cos_a * vy + sin_a * vx
end

-- project a onto b
function v2.project (ax, ay, bx, by)
  -- (a dot b) / (b dot b) * b
  local b_dot_b = vec2_dot (bx, by, bx, by)
  if b_dot_b == 0 then
    return 0, 0
  else
    local a_dot_b = vec2_dot (ax, ay, bx, by)
    local quotient = a_dot_b / b_dot_b
    return bx * quotient, by * quotient
  end
end

return v2
