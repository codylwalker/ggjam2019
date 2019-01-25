local help = {}

-- clamps a number to within a certain range
function help.clamp(low, n, high) return math.min(math.max(n, low), high) end

-- finds the modulo of a number within a range that starts with 1
function help.mod_list(index, length) return (index - 1) % length + 1 end

--- returns hex representation of num
function help.num_to_hex(num)
    local hex_str = '0123456789abcdef'
    local s = ''
    while num > 0 do
        local mod = math.fmod(num, 16)
        s = string.sub(hex_str, mod+1, mod+1) .. s
        num = math.floor(num / 16)
    end
    if s == '' then s = '0' end
    return s
end

-- Linear interpolation between two numbers.
function help.lerp(a,b,t) return a+(b-a)*t end

-- mathematical function producing an S-shape curve
function help.sigmoid (x)
  return 1 / (1 + math.exp(-x))
end

-- returns the sign for x where
-- positive = 1
-- negative = -1
-- zero = 0
function help.sign(x)
  return x>0 and 1 or x<0 and -1 or 0
end

-- random real number in [0, 1]
function help.random()
    return love.math.random()
end

-- random real number in [min, max]
function help.random_num(min, max)
    local r = love.math.random() * (max - min)
    return min + r
end

-- random integer in [min, max]
function help.random_int(min, max)
    return love.math.random(min, max)
end

-- random boolean value
function help.random_bool()
    return love.math.random(0, 1) == 1
end

-- random binomial between -1 and 1 where zero is more likely
function help.random_binomial()
    return help.random() - help.random()
end

-- shuffle the order of the elements inside a table
function help.shuffle(t)
    local n = #t

    while n >= 2 do
        -- n is now the last pertinent index
        local k = love.math.random(n) -- 1 <= k <= n
        -- Quick swap
        t[n], t[k] = t[k], t[n]
        n = n - 1
    end

    return t
end

-- reverses the order of items in a table
function help.reverse(t)
    local reversed = {}
    local count = #t
    for i, v in ipairs(t) do
        reversed[count + 1 - i] = v
    end
    return reversed
end

-- re-maps a number from one range to another
function help.map(value, old_min, old_max, new_min, new_max)
    assert(value >= old_min and value <= old_max, 'value must be inside original range')

    local old_range = old_max - old_min
    local new_range = new_max - new_min
    return (((value - old_min) * new_range) / old_range) + new_min
end

-- produces a random string of characters of a given length
function help.random_string(length)
    if length < 1 then return nil end

    local s = ""
    local n
    for i = 1, length do
        n = help.random_int(32, 126)

        if n == 96 then n = help.random_int(32, 95) end
        s = s .. string.char(n)
    end
    return s
end

function help.is_intersecting(a, b, c, d)
    local denominator = ((b.x - a.x) * (d.y - c.y)) - ((b.y - a.y) * (d.x - c.x))
    local numerator1 = ((a.y - c.y) * (d.x - c.x)) - ((a.x - c.x) * (d.y - c.y))
    local numerator2 = ((a.y - c.y) * (b.x - a.x)) - ((a.x - c.x) * (b.y - a.y))

    -- Detect coincident lines
    -- note: has a problem with coincidental lines that do not overlap
    if denominator == 0 then
        return numerator1 == 0 and numerator2 == 0
    end

    local r = numerator1 / denominator
    local s = numerator2 / denominator

    return (r >= 0 and r <= 1) and (s >= 0 and s <= 1);
end

return help
