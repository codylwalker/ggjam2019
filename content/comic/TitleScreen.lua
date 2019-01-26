import 'util'
import 'comic'

local TitleScreen = class 'TitleScreen'

function TitleScreen:init(parent_ctx)
  self.context = parent_ctx:new(self)
  self.text_alpha = 0
end

function TitleScreen:update(dt)
  if self.text_alpha < 1 then
    self.text_alpha = self.text_alpha + dt
  end
  print(self.text_alpha)
end


function TitleScreen:draw()
  local renderer = self.context.renderer

  -- love.graphics.setColor(1, 1, 1, self.text_alpha)

  love.graphics.setColor(1, 1, 1, self.text_alpha)
  renderer:draw_text('HYPERSPACE', self.context.resources.tiny_font, 0, 0.6, 0.4)
  
end

function TitleScreen:enter()
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
