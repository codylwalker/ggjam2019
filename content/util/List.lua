local class = require 'util.class'

local List = class 'List'

function List:init (data)
  if data then
    for i = 1, #data do
      self [i] = data [i]
    end
  end
end

List.ipairs = ipairs
List.items = ipairs

function List:clear ()
  for i = 1, #self do
    self [i] = nil
  end
end

function List:add (value)
  self [#self + 1] = value
end

function List:add_from (list)
  for i = 1, #list do
    self:add (list [i])
  end
end

List.insert = table.insert

function List:contains (value)
  return self:index_of (value) ~= nil
end

function List:index_of (value)
  for i = 1, #self do
    if self [i] == value then
      return i
    end
  end
end

function List:remove (value)
  local i = self:index_of (value)
  table.remove (self, i)
end

List.remove_at = table.remove

function List:newindex (index, value)
  if type (index) ~= 'number' then
    error ('assigning unknown index \'' .. tostring (index) ..
      '\' on ' .. tostring (self), 2)
  end
  if index ~= 1 and rawget (self, index - 1) == nil then
    error ('assigning nonconsecutive index ' .. index .. ' on ' .. tostring (self))
  end
  rawset (self, index, value)
end

function List:as_data ()
  local data = {'List {\n'}
  for i = 1, #self do
    local item = self [i]
    if type (item) == 'number' then
      table.insert (data, tostring (item) .. ',\n')
    else
      table.insert (data, self [i]:as_data () .. ',\n')
    end
  end
  table.insert (data, '}')
  return table.concat (data)
end

return List
