import 'util'
import 'comic'

local UiScreen = class 'UiScreen'

local function convert_world_to_screen(vec)
  local x, y = vec.x, vec.y
  local w, h = love.graphics.getDimensions ()
  x = (x * w) /(1920)
  y = (y * h) /(1080)
  return Vec2(x, y)
end


function UiScreen:init(parent_ctx)
  local w, h = love.graphics.getDimensions ()

  self.context = parent_ctx:new(self)

  self.intro_timer = Timer(self.context, 1)
  self.scan_timer = Timer(self.context, 4)
  self.scan_fade = Timer(self.context, 1.5)
  self.dance_intro_timer = Timer(self.context, 3)
  self.dance_async_timer = Timer(self.context, 3)
  self.dance_sync_timer = Timer(self.context, 5)
  self.outro_timer = Timer(self.context, 12)
  self.credits_timer = Timer(self.context, 5)
  self.quit_timer = Timer(self.context, 4)

  self.intro_timer.active = true

  self.ui_main_alpha = 1
  self.display_alpha = 1
  self.credits_alpha = 0
  self.ui_img = self.context.resources.images.ui_off
  self.scan_img = self.context.resources.images.ui_scan[1]

  local ui_display_offset = convert_world_to_screen(Vec2(190, 275))
  self.ui_display_pos = Vec2(w/2, h/2) - ui_display_offset

  self.frame = 0
  self.count = 0
end

function UiScreen:advance()
  if self.frame == 0 then
    self.count = 0 
    self.frame = 1
    self.ui_img = self.context.resources.images.ui_display[1]
    return
  end

  if self.frame == 1 then
    self.frame = 2
    return
  end

  if self.frame == 2 then
    self.frame = 3
    self.scan_timer.active = true
    return
  end

  if self.frame == 5 and self.dance_async_timer.complete then
      self.dance_sync_timer.active = true
    return
  end

  if self.outro_timer.complete then
    self.frame = 7
    self.credits_timer.active = true
  end

  if self.quit_timer.complete then
    love.event.quit()
  end

end


function UiScreen:update(dt)
  self.count = self.count + dt

  if self.frame == 1 then
    if self.count < 1.5 then 
      self.ui_img = self.context.resources.images.ui_display[1]
    elseif self.count < 3 then
      self.ui_img = self.context.resources.images.ui_display[2]
    else
      self.count = 0
    end
  end

  if self.frame == 2 or self.frame == 3 then
    if self.count < 1.5 then 
      self.ui_img = self.context.resources.images.ui_display[3]
    elseif self.count < 3 then
      self.ui_img = self.context.resources.images.ui_display[4]
    else
      self.count = 0
    end
  end

  if self.scan_timer.active then
    local frame = 8-math.ceil((self.scan_timer.value/self.scan_timer.length)*7)
    self.scan_img = self.context.resources.images.ui_scan[frame]
  end
  if self.scan_timer.event then 
    self.scan_timer.event = false
    self.scan_fade.active = true
  end

  if self.scan_fade.event then 
    self.scan_fade.event = false
    self.frame = 4
    self.dance_intro_timer.active = true
  end

  if self.frame == 4 or self.frame == 5 then
    self.ui_main_alpha = help.clamp(0, self.ui_main_alpha-dt*0.3, 1)
  end

  if self.dance_intro_timer.event then 
    self.dance_intro_timer.event = false
    self.dance_async_timer.active = true
    self.frame = 5
  end

  if self.frame == 5 then
    if self.count < 1.5 then 
      self.ui_img = self.context.resources.images.ui_async[1]
    elseif self.count < 3 then
      self.ui_img = self.context.resources.images.ui_async[2]
    elseif self.count < 4.5 then
      self.ui_img = self.context.resources.images.ui_async[3]
    else
      self.count = 0
    end
  end

  if self.dance_sync_timer.active then
    self.display_alpha = help.clamp(0, self.display_alpha - dt * 0.3, 1)
  end

  if self.dance_sync_timer.event then
    self.dance_sync_timer.event = false
    self.frame = 6
    self.outro_timer.active = true
  end

  if self.frame == 6 then
    self.display_alpha = help.clamp(0, self.display_alpha + dt * 0.3, 1)
    self.ui_main_alpha = help.clamp(0, self.ui_main_alpha+dt*0.3, 1)

    if self.count < 1.5 then 
      self.ui_img = self.context.resources.images.ui_sync[1]
    elseif self.count < 3 then
      self.ui_img = self.context.resources.images.ui_sync[2]
    elseif self.count < 4.5 then
      self.ui_img = self.context.resources.images.ui_sync[3]
    elseif self.count < 6 then
      self.ui_img = self.context.resources.images.ui_sync[4]
    else
      self.count = 0
      -- randomize position
      self.ui_img = self.context.resources.images.ui_sync[1]
      local w, h = love.graphics.getDimensions ()
      local ui_display_offset = convert_world_to_screen(Vec2(190, 275))
      self.ui_display_pos = Vec2(math.random()*w, math.random()*h) - ui_display_offset
    end
  end

  if self.frame == 7 then
    self.display_alpha = help.clamp(0, self.display_alpha - dt * 0.3, 1)
    self.ui_main_alpha = help.clamp(0, self.ui_main_alpha-dt*0.3, 1)
    if self.credits_timer.complete then
      self.credits_alpha = help.clamp(0, self.credits_alpha+dt*0.3, 1)
    end
  end

  if self.credits_timer.event then
    self.credits_timer.event = false
    self.quit_timer.active = true
  end

end


function UiScreen:mouse_pressed(x,y, button)
  self:advance()
end


function UiScreen:draw()
  local w, h = love.graphics.getDimensions ()
  local scale = w/1920

  love.graphics.push()
  love.graphics.reset()

  -- ui main
    if self.frame < 6 then
      love.graphics.setColor (1, 1, 1, self.ui_main_alpha)
      local ui_main = self.context.resources.images.ui_main
      local ui_main_offset = convert_world_to_screen(Vec2(751, 400))
      ui_main_offset = Vec2(w/2, h/2) - ui_main_offset
      love.graphics.draw(ui_main, ui_main_offset.x, ui_main_offset.y, 0, scale, scale)
    end
   if self.frame == 6 or self.frame == 7 then
      love.graphics.setColor (1, 1, 1, self.ui_main_alpha)
      local ui_main = self.context.resources.images.ui_main_sync
      love.graphics.draw(ui_main, 0, 0, 0, scale, scale)
    end

  -- ui display
    love.graphics.setColor (1, 1, 1, self.display_alpha)
    love.graphics.draw(self.ui_img, self.ui_display_pos.x, self.ui_display_pos.y, 0, scale, scale)

  -- scan
  if self.frame == 3 or self.frame == 4 then
    love.graphics.setColor (1, 1, 1, self.ui_main_alpha)
    local ui_scan_offset = convert_world_to_screen(Vec2(-110, 195))
    ui_scan_offset = Vec2(w/2, h/2) - ui_scan_offset
    love.graphics.draw(self.scan_img, ui_scan_offset.x, ui_scan_offset.y, 0, scale, scale)
  end

  -- credits
  if self.frame == 7 then
      love.graphics.setColor (1, 1, 1, self.credits_alpha)
      local credits = self.context.resources.images.credits
      local credits_offset = convert_world_to_screen(Vec2(273, 158.5))
      credits_offset = Vec2(w/2, h/2) - credits_offset
      love.graphics.draw(credits, credits_offset.x, credits_offset.y, 0, scale, scale)
  end

  love.graphics.pop()

end


return UiScreen
