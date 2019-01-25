import 'util'

-- convert +dither -colors 256 -dispose 3 -delay 2 -loop 0 test.png -crop 558x558 +repage -monitor test_out.gif

local FramePacker = class 'FramePacker'

function FramePacker:init ()
  -- twitter is 508 in timeline, 558 when expanded
  self.frame_width = 558
  self.frame_height = 558

  self.canvas_width = 2^14
  self.canvas_height = 2^13
  self.canvas = false

  self.encoding_thread = love.thread.newThread [[
    require 'love.image'
    local encoding_channel, status_channel = ...

    local running = true
    while running do
      print ('encoder: running')
      status_channel:push ('idle')
      local name = encoding_channel:demand ()
      if name then
        print ('encoder: writing ' .. name)
        status_channel:push ('writing')
        local image_data = encoding_channel:demand ()
        image_data:encode ('png', name)
        print ('encoder: creating gif ' .. name)
        status_channel:push ('converting')
        local in_path = love.filesystem.getRealDirectory (name) .. '/' .. name
        local out_path = love.filesystem.getRealDirectory (name) .. '/' .. name .. '.gif'
        local exit_code = os.execute (
          'convert +dither -colors 256 -dispose 3 -delay 2 -loop 0 "' ..
          in_path .. '" -crop 558x558 +repage -monitor "' .. out_path .. '[0-10]"')
        if exit_code ~= 0 then
          error ('error creating gif: ' .. exit_code)
        end
        print ('encoder: done')
      else
        running = false
      end
      collectgarbage ()
      collectgarbage ()
    end
  ]]

  self.encoding_channel = love.thread.newChannel ()
  self.status_channel = love.thread.newChannel ()
  self.status = 'idle'

  self.encoding_thread:start (self.encoding_channel, self.status_channel)

  self.index = 0
  --self:start()
end

function FramePacker:start ()
  self.index = 0
  if not self.canvas then
    self.canvas = love.graphics.newCanvas (
      self.canvas_width, self.canvas_height, { dpiscale = 1 })
    love.graphics.setCanvas (self.canvas)
    love.graphics.clear (0, 0, 0, 1)
    love.graphics.setCanvas ()
  end
end

function FramePacker:finish (name)
  local _, last_y = self:index_to_xy (math.max (0, self.index - 1))
  local width = math.floor (self.canvas_width / self.frame_width) * self.frame_width
  local height = math.min (last_y + self.frame_height, self.canvas:getHeight ())
  local image_data = self.canvas:newImageData (0, 1, 0, 0, width, height)
  --image_data:encode ('png', name)
  self.encoding_channel:push (name)
  self.encoding_channel:push (image_data)
  image_data:release ()
  love.graphics.setCanvas (self.canvas)
  love.graphics.clear (0, 0, 0, 1)
  love.graphics.setCanvas ()
end

function FramePacker:add_frame (frame)
  assert (frame:getWidth () == self.frame_width)
  assert (frame:getHeight () == self.frame_height)

  love.graphics.push ()
  love.graphics.origin ()
  if self.index == 0 then
    love.graphics.clear (0, 0, 0, 1)
  end
  love.graphics.setCanvas (self.canvas)
  local x, y = self:index_to_xy (self.index)
  love.graphics.setColor (1, 1, 1, 1)
  love.graphics.draw (frame, x, y)
  love.graphics.setCanvas ()
  love.graphics.pop ()

  self.index = self.index + 1
end

function FramePacker:index_to_xy (index)
  local cw, ch = self.canvas:getDimensions ()
  local cols = math.floor (cw / self.frame_width)
  local col = index % cols
  local row = math.floor (index / cols)

  return
    col * self.frame_width,
    row * self.frame_height
end

function FramePacker:update (dt)
  while self.status_channel:getCount () > 0 do
    self.status = self.status_channel:pop ()
  end
end

function FramePacker:draw ()
  if self.status ~= 'idle' then
    love.graphics.setColor (1, 0, 0, 1)
    love.graphics.print (self.status)
  end
end

return FramePacker
