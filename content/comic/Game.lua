import 'util'
import 'comic'

local Game = class 'Game'

function Game.provides:game()
  return self
end

function Game.provides:resources()
  return self.resources
end

function Game.provides:audio()
  return self.audio
end

function Game.provides:renderer()
  return self.renderer
end

function Game.get:is_portrait()
  local width, height = love.graphics.getDimensions()
  return width < height
end

function Game:init ()
  self.app = App ()
  self.context = self.app.context:new (self)

  print('-- start game --')

  -- load fonts
  self.small_font = love.graphics.newFont ('data/fonts/lato/Lato-Regular.ttf', 24)
  self.small_font:setFilter ('linear', 'linear')
  love.graphics.setFont(self.small_font)

  -- load resources
  self.resources = Resources(self.context)
  self.renderer = Renderer(self.context)
  self.audio = Audio(self.context)

  -- load scenes
  self.title_screen = TitleScreen(self.context)
  -- self.title_screen:enter()


end


function Game:get_dimensions ()
  local canvas = love.graphics.getCanvas ()
  if canvas then
    return canvas:getDimensions ()
  else
    return love.graphics.getDimensions ()
  end
end

function Game:get_screen_scale ()
  local w, h = self:get_dimensions ()
  return math.min (w/(2+1/8), h/(2+3/8))
end

function Game:get_screen_offset ()
  local w, h = self:get_dimensions ()
  return w/2, h/2
end

function Game:get_forward_position()
  local width, height = love.graphics.getDimensions()

  if self.is_portrait then
    local x,y = self:screen_to_world(0, height * 3/4)
    return 0, y - 1/2
  else
    local x = self:screen_to_world(width * 3/4, 0)
    return x + 1/2, 0
  end
end

function Game:get_back_position()
  local width, height = love.graphics.getDimensions()

  if self.is_portrait then
    local x,y = self:screen_to_world(0, height/4)
    return 0, y + 1/2
  else
    local x = self:screen_to_world(width/4, 0)
    return x - 1/2, 0
  end
end

function Game:screen_to_world (x, y)
  local scale = self:get_screen_scale ()
  local offset_x, offset_y = self:get_screen_offset ()
  return (x - offset_x) / scale, -(y - offset_y) / scale
end

function Game:screen_delta_to_world (dx, dy)
  local scale = self:get_screen_scale ()
  return dx / scale, -dy / scale
end

function Game.get:shift_held ()
  return love.keyboard.isDown ('lshift', 'rshift')
end

function Game.get:ctrl_held ()
  local os = love.system.getOS ()
  if os == 'OS X' or os == 'iOS' then
    return love.keyboard.isDown ('lgui', 'rgui')
  else
    return love.keyboard.isDown ('lctrl', 'rctrl')
  end
end

function Game:convert_screen_to_world(x, y)
  local scale = self:get_screen_scale ()
  local offset_x, offset_y = self:get_screen_offset ()

  x = (x - offset_x) / scale
  y = (y - offset_y) / -scale
  return x,y
end

function Game.listens:update(dt)
  self.title_screen:update(dt)
end


function Game.listens:draw ()
  self:_draw ()
end

function Game:_draw ()

  love.graphics.push ()
  local w, h = self:get_dimensions ()
  local scale = self:get_screen_scale ()
  local offset_x, offset_y = self:get_screen_offset ()
  love.graphics.translate (offset_x, offset_y)
  love.graphics.scale (scale, -scale)
  love.graphics.setLineWidth (1/scale)

  self.title_screen:draw()
  love.graphics.pop ()


  -- self:draw_fps()
end

function Game:draw_fps()
  love.graphics.setFont (self.small_font)
  love.graphics.print ('FPS: ' .. love.timer.getFPS (), 10, 0)
end

-- input
function Game.listens:mousemoved (x, y, dx, dy, is_touch)
end

function Game.listens:mousepressed (x, y, button, is_touch)
end

function Game.listens:mousereleased (x, y, button, is_touch)
end

function Game.listens:keypressed (key, scancode, is_repeat)

  -- toggle fullscreen
  if key == 'f' then
    love.window.setFullscreen(not love.window.getFullscreen ())


  -- quit
  elseif key == 'escape' then
      love.event.quit()
  -- f4: save screenshot
  elseif key == 'f4' then
    -- use the date & time as the screenshot file name
    local file_name = os.date('%Y-%m-%d (%Hh %Mm %Ss)')

    print("screenshot taken: " .. file_name)
    love.graphics.captureScreenshot(file_name .. '.png')

  -- f3: open screenshot folder
  elseif key == 'f3' then
    love.system.openURL("file://" .. love.filesystem.getSaveDirectory())
  end
end

function Game.listens:keyreleased (key, scancode)
end

return Game
