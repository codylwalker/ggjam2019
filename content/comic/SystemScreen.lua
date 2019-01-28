import 'util'
import 'comic'

local SystemScreen = class 'SystemScreen'

function SystemScreen:init(parent_ctx)
  self.context = parent_ctx:new(self)

  self.error_timer = Timer(self.context, 3)
  self.end_timer = Timer(self.context, 0)


  self.error_panel = self.context.resources.images.error_panel[1]

  self.frame = 0
  self.can_advance = false


end

function SystemScreen:update(dt)

  if self.error_timer.active then
    local frame = 9-math.ceil((self.error_timer.value/self.error_timer.length)*8)
    self.error_panel = self.context.resources.images.error_panel[frame]
  end

  if self.error_timer.event then
      self.error_timer.event = false
      self.can_advance = true
  end

  if self.end_timer.event then
      self.end_timer.event = false
      self.context.game.system_screen_active = false
      self.context.game.ui_screen_active = true
  end

  self:check_complete()
end

local function convert_world_to_screen(vec)
  local x, y = vec.x, vec.y
  local w, h = love.graphics.getDimensions ()
  x = (x * w) /(1920)
  y = (y * h) /(1080)
  return Vec2(x, y)
end

function SystemScreen:mouse_pressed(x,y, button)
  self:advance()
end

function SystemScreen:advance()
  if not self.can_advance then return end
  self.frame = self.frame + 1

  if self.frame == 5 then
    self.end_timer.active = true
  end
end

function SystemScreen:check_complete()
  if self.end_timer.complete then
    self.context.game.system_screen_active = false
    self.context.game.ui_screen_active = true
  end
end


function SystemScreen:draw()
  local w, h = love.graphics.getDimensions ()
  local scale = w/1920

  love.graphics.push()
  love.graphics.reset()

  -- error panel
  if self.frame == 0 then
    local error_offset = convert_world_to_screen(Vec2(519, 161))
    error_offset = Vec2(w/2, h/2) - error_offset -- center

    love.graphics.draw(self.error_panel, error_offset.x, error_offset.y, 0, scale, scale)
  end


  love.graphics.setColor (1, 1, 1, 1)
  if self.frame >= 1 and self.frame < 5 then
    local frame1 = self.context.resources.images.frame1
    local f1_offset = convert_world_to_screen(Vec2(390, 140))
    love.graphics.draw(frame1, f1_offset.x, f1_offset.y, 0, scale, scale)
  end


  if self.frame >= 2 and self.frame < 5 then
    local frame2 = self.context.resources.images.frame2
    local f2_offset = convert_world_to_screen(Vec2(540, 340))
    love.graphics.draw(frame2, f2_offset.x, f2_offset.y, 0, scale, scale)
  end

  if self.frame >= 3 and self.frame < 5 then
    local frame3 = self.context.resources.images.frame3
    local f3_offset = convert_world_to_screen(Vec2(990, 215))
    love.graphics.draw(frame3, f3_offset.x, f3_offset.y, 0, scale, scale)
  end

  if self.frame >= 4 and self.frame < 5 then
    local frame4 = self.context.resources.images.frame4
    local f4_offset = convert_world_to_screen(Vec2(990, 565))
    love.graphics.draw(frame4, f4_offset.x, f4_offset.y, 0, scale, scale)
  end

  love.graphics.pop()

end


return SystemScreen
