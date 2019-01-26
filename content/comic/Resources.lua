import 'util'
import 'comic'

local Resources = class 'Resources'

function Resources:init(parent_ctx)
  self.context = parent_ctx:new(self)
  self.sounds = require 'comic.sounds'
  self.images = require 'comic.images'

  -- music properties
  self.music_sound = false
  self.music_fade_ratio = 0
  self.next_music_sound = false

  -- graphics
  self.images = require 'comic.images'
  self.white_pixel = love.graphics.newImage (love.image.newImageData (1, 1, 'rgba8', '\255\255\255\255'))
  self.text_shader = love.graphics.newShader ('data/shaders/text_shader.glsl')

  -- fonts
  self.tiny_font = love.graphics.newFont ('data/fonts/lato/Lato-Regular.ttf', 128)

end


return Resources
