local function class (name)
  local init_flag = {}
  local object_name = '<' .. name .. '>'

  -- initialise a new class object ---------------
  local new_class = setmetatable ({}, {
    __call = function (obj, ...)
      return obj.new (...)
    end
  })

  new_class.get = {}
  new_class.set = {}
  new_class.provides = {}
  new_class.listens = {}
  new_class.metatable = {}
  new_class.metatable.class = new_class

  -- basic class functions -----------------------

  new_class.is_type_of = function (object)
    return getmetatable (object) == new_class.metatable
  end

  -- instance metamethods ------------------------
  function new_class.metatable:__tostring ()
    return object_name
  end

  function new_class.metatable:__index (key)
    if new_class.get [key] then
      return new_class.get [key] (self)
    elseif new_class [key] then
      return new_class [key]
    elseif new_class.index then
      return new_class.index (self, key)
    else
      error ('reading unknown field \'' .. tostring (key) ..
        '\' on ' .. tostring (self), 2)
    end
  end

  function new_class:has (key)
    return
      (type(self) == 'table' and rawget (self, key) ~= nil) or
      new_class.get [key] or
      new_class [key] ~= nil or
      new_class.index
  end

  function new_class.metatable:__newindex (key, value)
    local ts = tostring
    -- set
    if new_class.set [key] then
      new_class.set [key] (self, value)
    -- get, no set
    elseif new_class.get [key] then
      error ('assigning read-only field ' .. ts (key) .. ' on ' .. ts (self), 2)
    -- can't shadow class fields on instances
    elseif new_class [key] then
      error ('assigning class field ' .. ts (key) .. ' on ' .. ts (self), 2)
    -- custom newindex, use rawset to create new regular fields
    elseif new_class.newindex then
      new_class.newindex (self, key, value)
    -- allow new fields during init
    elseif type(self) == 'table' and rawget (self, init_flag) then
      rawset (self, key, value)
    -- otherwise nope!
    else
      error ('assigning unknown field ' .. ts (key) .. ' on ' .. ts (self), 2)
    end
  end

  -- new -----------------------------------------
  function new_class.new (...)
    local self = setmetatable ({}, new_class.metatable)
    if self:has 'init' then
      rawset (self, init_flag, true)
      self:init (...)
      rawset (self, init_flag, nil)
    end
    return self
  end

  return new_class
end

return class
