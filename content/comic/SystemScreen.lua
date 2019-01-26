import 'util'
import 'comic'

local SystemScreen = class 'SystemScreen'

function SystemScreen:init(parent_ctx)
  self.context = parent_ctx:new(self)
end

function SystemScreen:update(dt)
end

local function convert_world_to_screen(vec)
  local x, y = vec.x, vec.y
  local w, h = love.graphics.getDimensions ()
  x = (x * w) /(1920)
  y = (y * h) /(1080)
  return Vec2(x, y)
end

function SystemScreen:draw()
  local w, h = love.graphics.getDimensions ()
  local scale = w/1920

  love.graphics.push()
  love.graphics.reset()


  local offset = Vec2(390, 140)
  offset = convert_world_to_screen(offset)

  love.graphics.setColor (1, 1, 1, 1)
  local frame1 = self.context.resources.images.frame1

  love.graphics.draw(frame1, offset.x, offset.y, 0, scale, scale)
  love.graphics.setColor (1, 1, 1, 1)
  love.graphics.pop()

end


return SystemScreen
