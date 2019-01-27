import 'util'
import 'comic'

local TitleScreen = class 'TitleScreen'

function TitleScreen:init(parent_ctx)
  self.context = parent_ctx:new(self)
  self.title_alpha = 0
  self.title_count = 0.35
  self.title_index = 1
  self.title = self.context.resources.images.title[1]
  self.starfield = Starfield(self.context)

  -- timers
  self.intro_timer = Timer(self.context, 3)
  self.title_intro_timer = Timer(self.context, 2)
  self.title_timer = Timer(self.context, 1.5)
  self.title_fade_timer = Timer(self.context, 2)
  -- self.intro_timer = Timer(self.context, 0)
  -- self.title_intro_timer = Timer(self.context, 0)
  -- self.title_timer = Timer(self.context, 0)
  -- self.title_fade_timer = Timer(self.context, 0)

  self.starfield_intro_timer = Timer(self.context, 4)
  self.starfield_timer = Timer(self.context, 2)

  self.intro_timer.active = true
end


local function timer_event(end_timer, start_timer)
  if end_timer.event then
    end_timer.event = false
    start_timer.active = true
  end
end

function TitleScreen:update(dt)

  -- timer sequence
  timer_event(self.intro_timer, self.title_intro_timer)
  timer_event(self.title_intro_timer, self.title_timer)
  timer_event(self.title_timer, self.title_fade_timer)
  timer_event(self.title_fade_timer, self.starfield_intro_timer)
  timer_event(self.starfield_intro_timer, self.starfield_timer)

  -- fade with timers
  if self.title_intro_timer.active then
    local alpha = self.title_alpha + dt/self.title_intro_timer.length
    self.title_alpha = help.clamp(0, alpha, 1)
  end

  if self.title_fade_timer.active then
    local alpha = self.title_alpha - dt/self.title_fade_timer.length
    self.title_alpha = help.clamp(0, alpha, 1)
  end

  if self.starfield_intro_timer.active then
    local alpha = self.starfield.alpha + dt/self.starfield_intro_timer.length
    self.starfield.alpha = help.clamp(0, alpha, 1)
  end


  self.title_count = self.title_count - dt
  if self.title_count <= 0 then
    self.title_count = 0.35
    self.title_index = (self.title_index + 1)%3 + 1
    self.title = self.context.resources.images.title[self.title_index]
  end



  self.starfield:update(dt)

end

function TitleScreen:check_complete()
  if self.starfield_timer.complete then
    self.context.game.title_screen_active = false
    self.context.game.system_screen_active = true
  end
end


local function convert_world_to_screen(vec)
  local x, y = vec.x, vec.y
  local w, h = love.graphics.getDimensions ()
  x = (x * w) /(1920)
  y = (y * h) /(1080)
  return Vec2(x, y)
end

function TitleScreen:draw()
  -- draw title
  love.graphics.push()
  love.graphics.reset()

  local w, h = love.graphics.getDimensions ()
  local scale = w/1920

  local offset = convert_world_to_screen(Vec2(238, 45))
  offset = Vec2(w/2, h/2) - offset -- center

  love.graphics.setColor(1, 1, 1, self.title_alpha)

  love.graphics.draw(self.title, offset.x, offset.y, 0, scale, scale)

  love.graphics.pop()

    love.graphics.setColor(1, 1, 1, 1)
  -- end

  -- if self.starfield_timer.active then
    self.starfield:draw()
  -- end

end

function TitleScreen:mouse_pressed(x,y, button)
  self:check_complete()
end

function TitleScreen:key_pressed(key)
  if key == 'space' then
  self:check_complete()
    -- advance?
  end
end

function TitleScreen:mouse_released(x,y)
end

return TitleScreen
