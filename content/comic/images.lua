local image_path = 'data/images/'

local function new_image(path, options)
  return love.graphics.newImage (image_path .. path, options)
end

local images = 
{
  fool = new_image('0_the_fool.png'),
}

return images
