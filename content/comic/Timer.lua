import 'util'
import 'comic'

local Timer = class 'Timer'


function Timer:init(parent_ctx, time)
  self.context = parent_ctx:new(self) -- we need parent_ctx for timer to listen to the context's update
  self.active = false
  self.length = time
  self.value = time
  self.complete = false
  self.event = false
end

function Timer.listens:update(dt)
  if self.active and not self.complete then
    self.value = self.value - dt

    if self.value <= 0 then
      self.event = true
      self.complete = true
      self.active = false
    end
  end
end


return Timer
