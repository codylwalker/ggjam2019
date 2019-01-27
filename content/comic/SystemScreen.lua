import 'util'
import 'comic'

local SystemScreen = class 'SystemScreen'

function SystemScreen:init(parent_ctx)
  self.context = parent_ctx:new(self)

  self.intro_timer = Timer(self.context, 0)
  self.error_timer = Timer(self.context, 4)
  self.intro_timer.active = true

  self.show_error = false
  self.error_panel = self.context.resources.images.error_panel[1]

end

function SystemScreen:update(dt)

  if self.intro_timer.event then
      self.intro_timer.event = false
      self.error_timer.active = true
      self.show_error = true
  end

  if self.error_timer.active then
    local frame = 8-math.floor((self.error_timer.value/self.error_timer.length)*7)
      self.error_panel = self.context.resources.images.error_panel[frame]
  end

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



  -- error panel
  if self.show_error then

    local error_offset = convert_world_to_screen(Vec2(519, 161))
    error_offset = Vec2(w/2, h/2) - error_offset -- center

    love.graphics.draw(self.error_panel, error_offset.x, error_offset.y, 0, scale, scale)
  end


  -- love.graphics.setColor (1, 1, 1, 1)
  -- local frame1 = self.context.resources.images.frame1
  -- local f1_offset = convert_world_to_screen(Vec2(390, 140))
  -- love.graphics.draw(frame1, f1_offset.x, f1_offset.y, 0, scale, scale)

  -- local frame2 = self.context.resources.images.frame2
  -- local f2_offset = convert_world_to_screen(Vec2(540, 340))
  -- love.graphics.draw(frame2, f2_offset.x, f2_offset.y, 0, scale, scale)

  -- local frame3 = self.context.resources.images.frame3
  -- local f3_offset = convert_world_to_screen(Vec2(990, 215))
  -- love.graphics.draw(frame3, f3_offset.x, f3_offset.y, 0, scale, scale)

  -- local frame4 = self.context.resources.images.frame4
  -- local f4_offset = convert_world_to_screen(Vec2(990, 565))
  -- love.graphics.draw(frame4, f4_offset.x, f4_offset.y, 0, scale, scale)

  love.graphics.pop()

end


return SystemScreen
