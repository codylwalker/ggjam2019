import 'util'

local Context = class 'Context'

function Context.get:parent ()
  return self._parent
end

function Context:init (parent, object)
  self._parent = parent
  self._children = {}

  self.removed = Event ()
  self.removed.reverse_order = true
  if parent and parent.removed then
    parent.removed:listen_until (self.removed, self.removed)
  end

  if parent then
    table.insert (parent._children, self)
    self.removed:listen (function ()
      for i = #parent._children, 1, -1 do
        if parent._children[i] == self then
          table.remove (parent._children, i)
          break
        end
      end
    end)
  end

  self.object = object or false
  if object then
    if object:has 'listens' then
      for event, listener in pairs (object.listens) do
        if not Event.is_type_of (event) then
          local key = event
          event = self [key]
          if not event then
            error ('couldn\'t find event "' .. tostring (key) .. '"' .. ' listened by ' .. tostring (object), 1)
          end
        end
        event:listen_until (self.removed, function (...)
          listener (object, ...)
        end)
      end
    end
  end
end

function Context:index (key)
  if self.object and self.object:has 'provides' and self.object.provides [key] then
    return self.object.provides [key] (self.object)
  elseif self._parent then
    return self._parent [key]
  end
end

function Context:newindex (key, value)
  rawset (self, key, value)
end

function Context:listen (event, fn, fn_self)
  if fn_self then
    event:listen_until (self.removed, function (...)
      fn (fn_self, ...)
    end)
  else
    event:listen_until (self.removed, fn)
  end
end

return Context
