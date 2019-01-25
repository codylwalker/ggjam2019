local class = require 'util.class'

local Event = class 'Event'

function Event:init ()
  self.reverse_order = false
  self._count = 0
  self._indices = {}
  self._handlers = {}
  self._running = 0
end

function Event:call (...)
  local handlers_length = #self._handlers
  if handlers_length > 0 then
    self._running = self._running + 1
    -- loop depending on self.reverse_order
    local first, last, step = 1, handlers_length, 1
    if self.reverse_order then
      first, last, step = handlers_length, 1, -1
    end
    -- call all handlers
    for i = first, last, step do
      local f = self._handlers [i]
      if f then
        f (...)
      end
    end
    -- all done
    self._running = self._running - 1
    self:_filter_if_appropriate ()
  end
end
Event.metatable.__call = Event.call

function Event:listen (f)
  assert (f ~= nil)
  assert (self._indices [f] == nil, 'duplicate handler')

  self._count = self._count + 1
  local new_index = #self._handlers + 1
  self._handlers[new_index] = f
  self._indices[f] = new_index
end

function Event:listen_until (removal_event, f)
  assert (removal_event)

  local function remove_fn ()
    self:remove (f)
    removal_event:remove (remove_fn)
  end

  if removal_event.reverse_order then
    removal_event:listen (remove_fn)
    self:listen (f)
  else
    self:listen (f)
    removal_event:listen (remove_fn)
  end
end

function Event:remove (f)
  assert (f ~= nil)
  assert (self._indices [f] ~= nil, 'handler not found')
  self._handlers [self._indices[f]] = false
  self._indices [f] = nil
  self._count = self._count - 1
  self:_filter_if_appropriate ()
end

function Event:_filter_if_appropriate ()
  if self._running == 0 and self._count < #self._handlers / 2 then
    local compact_handlers = {}
    local c = 1
    for i = 1, #self._handlers do
      local h = self._handlers[i]
      if h then
        compact_handlers[c] = h
        self._indices[h] = c
        c = c + 1
      end
    end
    self._handlers = compact_handlers
  end
end

return Event
