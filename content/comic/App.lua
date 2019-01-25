import 'util'
import 'comic'

local App = class 'App'

function App.provides:draw () return self.draw end
function App.provides:update () return self.update end
function App.provides:resize () return self.resize end
function App.provides:keypressed () return self.keypressed end
function App.provides:keyreleased () return self.keyreleased end
function App.provides:mousemoved () return self.mousemoved end
function App.provides:mousepressed () return self.mousepressed end
function App.provides:mousereleased () return self.mousereleased end
function App.provides:wheelmoved () return self.wheelmoved end
function App.provides:filedropped () return self.filedropped end

function App:init ()
  self.context = Context (false, self)
  self.draw = Event ()
  self.update = Event ()
  self.resize = Event ()
  self.keypressed = Event ()
  self.keyreleased = Event ()
  self.mousemoved = Event ()
  self.mousepressed = Event ()
  self.mousereleased = Event ()
  self.wheelmoved = Event ()
  self.filedropped = Event ()
end

App.listens [love.update] = function (self, dt)
  dt = math.min (dt, 0.1)
  self.update (dt)
end

App.listens [love.draw] = function (self)
  self.draw ()
end

App.listens [love.resize] = function (self, w, h)
  self.resize (w, h)
end

App.listens [love.keypressed] = function (self, key, scancode, is_repeat)
  if scancode == 'r' and love.keyboard.isDown ('lctrl', 'rctrl', 'lgui', 'rgui') then
    love.event.quit ('restart')
  end

  self.keypressed (key, scancode, is_repeat)
end

App.listens [love.keyreleased] = function (self, key, scancode)
  self.keyreleased (key, scancode)
end

App.listens [love.mousemoved] = function (self, x, y, dx, dy, is_touch)
  self.mousemoved (x, y, dx, dy, is_touch)
end

App.listens [love.mousepressed] = function (self, x, y, button, is_touch)
  self.mousepressed (x, y, button, is_touch)
end

App.listens [love.mousereleased] = function (self, x, y, button, is_touch)
  self.mousereleased (x, y, button, is_touch)
end

App.listens [love.wheelmoved] = function (self, x, y)
  self.wheelmoved (x, y)
end

App.listens [love.filedropped] = function (self, file)
  self.filedropped (file)
end

return App
