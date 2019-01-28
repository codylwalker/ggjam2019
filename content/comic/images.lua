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
    new_image('ErrorPanel_ANIMS/ErrorPanel_Anims08.png')},
  ui_main = new_image('UI_Interface/UI_Interface_Main.png'),
  ui_main_sync = new_image('UI_Interface/UI_Interface-Synced.png'),
  ui_off = new_image('UI_Interface/UI_Interface_MainDisplay_OFF.png'),
  ui_display = {
    new_image('UI_Interface/UI_Interface_MainDisplay_01.png'),
    new_image('UI_Interface/UI_Interface_MainDisplay_02.png'),
    new_image('UI_Interface/UI_Interface_MainDisplay_03.png'),
    new_image('UI_Interface/UI_Interface_MainDisplay_04.png')},
  ui_scan = {
    new_image('UI_Xeno_readout/UI_Interface_MainDisplay_Readout_01.png'),
    new_image('UI_Xeno_readout/UI_Interface_MainDisplay_Readout_02.png'),
    new_image('UI_Xeno_readout/UI_Interface_MainDisplay_Readout_03.png'),
    new_image('UI_Xeno_readout/UI_Interface_MainDisplay_Readout_04.png'),
    new_image('UI_Xeno_readout/UI_Interface_MainDisplay_Readout_05.png'),
    new_image('UI_Xeno_readout/UI_Interface_MainDisplay_Readout_06.png'),
    new_image('UI_Xeno_readout/UI_Interface_MainDisplay_Readout-Error.png')},
  ui_async = {
    new_image('UI_Interface/UI_Interface_MainDisplay_UnSync_01.png'),
    new_image('UI_Interface/UI_Interface_MainDisplay_UnSync_02.png'),
    new_image('UI_Interface/UI_Interface_MainDisplay_UnSync_03.png')},
  ui_sync = { 
    new_image('UI_Interface/UI_Interface_MainDisplay_InSync_01.png'),
    new_image('UI_Interface/UI_Interface_MainDisplay_InSync_02.png'),
    new_image('UI_Interface/UI_Interface_MainDisplay_InSync_03.png'),
    new_image('UI_Interface/UI_Interface_MainDisplay_InSync_04.png')},
  credits = new_image('Credits.png'),
}

return images
