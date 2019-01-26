import 'util'
import 'comic'

local SystemScreen = class 'SystemScreen'

function SystemScreen:init(parent_ctx)
  self.context = parent_ctx:new(self)
end

function SystemScreen:update(dt)
end

function SystemScreen:draw()
end


return SystemScreen
