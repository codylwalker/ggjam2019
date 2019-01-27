import 'util'
import 'comic'

local TitleScreen = class 'TitleScreen'

function TitleScreen:init(parent_ctx)
  self.context = parent_ctx:new(self)
  self.text_alpha = 0
  self.starfield = Starfield(self.context)

  -- timers
  -- self.intro_timer = Timer(self.context, 3)
  -- self.title_intro_timer = Timer(self.context, 2)
  -- self.title_timer = Timer(self.context, 1.5)
  -- self.title_fade_timer = Timer(self.context, 2)
  self.intro_timer = Timer(self.context, 0)
  self.title_intro_timer = Timer(self.context, 0)
  self.title_timer = Timer(self.context, 0)
  self.title_fade_timer = Timer(self.context, 0)

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
    local alpha = self.text_alpha + dt/self.title_intro_timer.length
    self.text_alpha = help.clamp(0, alpha, 1)
  end

  if self.title_fade_timer.active then
    local alpha = self.text_alpha - dt/self.title_fade_timer.length
    self.text_alpha = help.clamp(0, alpha, 1)
  end

  if self.starfield_intro_timer.active then
    local alpha = self.starfield.alpha + dt/self.starfield_intro_timer.length
    self.starfield.alpha = help.clamp(0, alpha, 1)
  end

  self.starfield:update(dt)
end


function TitleScreen:draw()
  local renderer = self.context.renderer

  -- if self.title_intro_timer.active or self.title_timer.active or self.title_fade_timer.active then
    love.graphics.setColor(1, 1, 1, self.text_alpha)
    -- renderer:draw_text(tostring(self.text_alpha), self.context.resources.tiny_font, 0, 0.95, 0.2)
    renderer:draw_text('HEART IN STASIS', self.context.resources.tiny_font, 0, 0.95, 0.2)
    love.graphics.setColor(1, 1, 1, 1)
  -- end

  -- if self.starfield_timer.active then
    self.starfield:draw()
  -- end

end

function TitleScreen:mouse_pressed(x,y)
end

function TitleScreen:key_pressed(key)
  if key == 'space' then
    -- advance?
  end
end

function TitleScreen:mouse_released(x,y)
end

return TitleScreen
