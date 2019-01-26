import 'util'
import 'comic'

local Renderer = class 'Renderer'

function Renderer:init(parent_ctx)
  self.context = parent_ctx:new(self)
end

function Renderer:draw_shape (draw_mode, x, y, w, h, radius, color_outer, color_border, color_inner, image)
  color_outer = color_outer or {1, 1, 1, 1}
  color_border = color_border or (draw_mode == 'fill' and color_outer or {1, 1, 1, 0})
  color_inner = color_inner or color_border
  local shader = self.context.resources.part_shader
  love.graphics.setShader (shader)
  local padding = 1 / self.context.game:get_screen_scale ()
  shader:send ('padding', padding)
  shader:send ('size', {w, h})
  shader:send ('radius', radius)
  shader:sendColor ('color_outer', color_outer)
  shader:sendColor ('color_border', color_border)
  shader:sendColor ('color_inner', color_inner)
  local bw = w + padding * 2
  local bh = h + padding * 2
  image = image or self.context.resources.white_pixel
  love.graphics.draw (image, x - bw/2, y - bh/2, 0, bw / image:getWidth (), bh / image:getHeight ())
  love.graphics.setShader ()
end

function Renderer:draw_text (text, font, x, y, scale, align_top_left)
  local font_width = font:getWidth (text)
  local font_height = font:getHeight ()
  local fontscale = scale / font_height

  local pos_x = align_top_left and x or x - fontscale * font_width / 2
  local pos_y = align_top_left and y or y + fontscale * font_height / 2
  love.graphics.setFont(font)
  love.graphics.setShader (self.context.resources.text_shader)
  love.graphics.print (text,
    pos_x,
    pos_y,
    0, fontscale, -fontscale)
  love.graphics.setShader ()
end

function Renderer:draw_star(x, y, is_collected, scale)
  local scale = scale or 1
  local resources = self.context.resources
  local image = is_collected and resources.images.star_fill or resources.images.star_outline
  local scale = 0.18/image:getHeight() * scale
  love.graphics.draw(image, x, y, 0, scale, -scale, image:getWidth()/2, image:getHeight()/2)
end

return Renderer
