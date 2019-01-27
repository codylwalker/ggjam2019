local image_path = 'data/images/'

local function new_image(path, options)
  return love.graphics.newImage (image_path .. path, options)
end

local images = 
{
  title = {
    new_image('title/Logo_Anim_01.png'),
    new_image('title/Logo_Anim_02.png'),
    new_image('title/Logo_Anim_03.png')},
  blotter = new_image('starfield-blotter.png'),
  frame1 = new_image('frame1.png'),
  frame2 = new_image('frame2.png'),
  frame3 = new_image('frame3.png'),
  frame4 = new_image('frame4.png'),
  error_panel = {
    new_image('ErrorPanel_ANIMS/ErrorPanel_Anims00.png'),
    new_image('ErrorPanel_ANIMS/ErrorPanel_Anims01.png'),
    new_image('ErrorPanel_ANIMS/ErrorPanel_Anims02.png'),
    new_image('ErrorPanel_ANIMS/ErrorPanel_Anims03.png'),
    new_image('ErrorPanel_ANIMS/ErrorPanel_Anims04.png'),
    new_image('ErrorPanel_ANIMS/ErrorPanel_Anims05.png'),
    new_image('ErrorPanel_ANIMS/ErrorPanel_Anims06.png'),
    new_image('ErrorPanel_ANIMS/ErrorPanel_Anims07.png'),
    new_image('ErrorPanel_ANIMS/ErrorPanel_Anims08.png')}
}

return images
