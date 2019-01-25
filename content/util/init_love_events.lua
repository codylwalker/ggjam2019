local Event = require 'util.Event'

-- shareable events for love callbacks -----------

love.directorydropped = Event ()
love.draw = Event ()
love.filedropped = Event ()
love.focus = Event ()
love.keypressed = Event ()
love.keyreleased = Event ()
love.load = Event ()
love.lowmemory = Event ()
love.mousefocus = Event ()
love.mousemoved = Event ()
love.mousepressed = Event ()
love.mousereleased = Event ()
love.quit = Event ()
love.resize = Event ()
love.textedited = Event ()
love.textinput = Event ()
love.touchmoved = Event ()
love.touchpressed = Event ()
love.touchreleased = Event ()
love.update = Event ()
love.visible = Event ()
love.wheelmoved = Event ()
love.gamepadaxis = Event ()
love.gamepadpressed = Event ()
love.gamepadreleased = Event ()
love.joystickadded = Event ()
love.joystickaxis = Event ()
love.joystickhat = Event ()
love.joystickpressed = Event ()
love.joystickreleased = Event ()
love.joystickremoved = Event ()

-- new callbacks
love.start_of_frame = Event ()
love.end_of_frame = Event ()


-- main loop -------------------------------------
-- based on https://love2d.org/wiki/love.run 0.10.0

function love.run ()
  love.math.setRandomSeed (os.time ())
	love.load (arg)
	love.timer.step ()

  local next_draw_time = love.timer.getTime ()
 
	-- main loop
	local dt = 0
	while true do
    love.start_of_frame ()
		-- events
    love.event.pump ()
    for name, a, b, c, d, e, f in love.event.poll () do
      if name == "quit" and (not love.quit or not love.quit ()) then
        return a
      end
      love.handlers [name] (a, b, c, d, e, f)
    end
 
		-- delta time
    love.timer.step ()
    dt = love.timer.getDelta ()
 
		-- update
		love.update (dt)
 
    -- draw
		if love.graphics.isActive () then
      love.graphics.clear (love.graphics.getBackgroundColor ())
			love.graphics.origin ()
			love.draw ()
			love.graphics.present ()
		end
 
    love.end_of_frame ()

    collectgarbage ('step', 1)

    -- limit framerate
    local time = love.timer.getTime ()
    if time < next_draw_time then
      love.timer.sleep (next_draw_time - time)
    end
    local w, h, flags = love.window.getMode ()
    local rate = flags.refreshrate
    if rate == 0 then rate = 60 end
    local delay = flags.vsync and 1/(rate + 10) or 1/rate
    next_draw_time = love.timer.getTime () + delay
  end
end


-- error handling --------------------------------
-- based on https://love2d.org/wiki/love.errhand 0.10.0

local function error_printer (msg, layer)
end

local function handle_error (msg)
	msg = tostring (msg)

  -- print error
	print (debug.traceback ("Error: " .. msg, 4))

  -- do nothing if modules not available
	if not love.window or not love.graphics or not love.event then
		return
	end

  -- open a window if needed
	if not love.graphics.isCreated () or not love.window.isOpen () then
		local success, status = pcall (love.window.setMode, 800, 600)
		if not success or not status then
			return
		end
	end

	-- reset mouse
	if love.mouse then
		love.mouse.setVisible (true)
		love.mouse.setGrabbed (false)
		love.mouse.setRelativeMode (false)
	end

  -- reset joystick vibration
	if love.joystick then
		for i, v in ipairs (love.joystick.getJoysticks ()) do
			v:setVibration ()
		end
	end

  -- stop audio
	if love.audio then
    love.audio.stop ()
  end

  -- reset graphics
	love.graphics.reset ()
	local error_font = love.graphics.setNewFont (16)
	local source_font = love.graphics.setNewFont (12)
  error_font:setLineHeight (1.25)
  source_font:setLineHeight (1.25)
	love.graphics.setBackgroundColor (1/15, 1/15, 1/15)
	love.graphics.setColor (1, 1, 1, 1)
	love.graphics.clear (love.graphics.getBackgroundColor ())
	love.graphics.origin ()

  -- colors
  local c_dark = {96/255, 96/255, 96/255}
  local c_mid = {150/255, 150/255, 150/255}
  local c_bright = {240/255, 240/255, 240/255}
  local c_interact = {240/255, 240/255, 240/255}
 
  -- get the backtrace
	local trace = debug.traceback ('', 4)
  -- what location does the error target
  local target_file, target_linenum, msg_without_target = msg:match '^([^:]-%.lua):([^:]-): ?(.*)'
  if target_file then
    target_linenum = tonumber (target_linenum)
    msg = msg_without_target
  end

  local text
  local source_text
  local stack_count
  local stack_index
  local function refresh_text ()
    -- prepare backtrace text
    text = {}
    local current_file
    local current_linenum
    table.insert (text, c_dark)
    table.insert (text, "Error: ")
    table.insert (text, {240, 240, 240})
    table.insert (text, msg)
    
    table.insert (text, c_dark)
    table.insert (text, "\n")
    local location_index = 0
    for line in string.gmatch (trace, "(.-)\n") do
      if not string.match (line, "boot.lua") and
         not string.match (line, "stack traceback:") then
        line = line:gsub ('\t', '')
        local file, linenum, rest = line:match '(.-):(.-)(:.*)'
        if file then
          linenum = tonumber (linenum)
          location_index = location_index + 1

          -- if we're still trying to find the right stack index and this one matches ..
          if not stack_index and target_file == file and target_linenum == linenum then
            -- select it and remove the location info them the message
            stack_index = location_index
          end

          table.insert (text,
            stack_index == location_index and c_interact or c_mid)
          table.insert (text, file .. ':' .. linenum)
          table.insert (text,
            stack_index == location_index and c_interact or c_dark)
          table.insert (text, rest .. '\n')

          if location_index == stack_index then
            current_file = file
            current_linenum = linenum
          end
        else
          table.insert (text, c_dark)
          table.insert (text, line .. '\n')
        end
      end
    end
    stack_count = location_index
    if not stack_index then
      stack_index = 1
    end

    -- show source
    local source_available
    if current_file then
      source_available = assert(pcall (function ()
        local first_line = current_linenum - 10
        local last_line = current_linenum + 10
        local num = 0
        source_text = {c_dark, '' .. current_file .. '\n\n'}
        for line in love.filesystem.read (current_file):gmatch ("(.-)\r?\n") do
          num = num + 1
          if num >= first_line and num <= last_line then
            table.insert (source_text,
              num == current_linenum and c_bright or c_dark)
            table.insert (source_text, string.format ("%.2d\t%s\n", num, line))
          end
        end
      end))
    end
    if not source_available then
      source_text = {c_dark, 'source not available'}
      stack_count = 0
    end
    stack_index = math.min(stack_count, stack_index)
  end
  refresh_text ()

  -- main loop
	while true do
    -- handle events
    love.event.pump ()
    for e, a, b, c in love.event.poll () do
      if e == "quit" or e == "keypressed" and a == "escape" then
        return
      elseif e == "keypressed" and (a == "up" or a == 'k') then
        stack_index = math.max (1, stack_index - 1)
        refresh_text ()
      elseif e == "keypressed" and (a == "down" or a == 'j') then
        stack_index = math.min(stack_count, stack_index + 1)
        refresh_text ()
      elseif e == "touchpressed" then
        local name = love.window.getTitle ()
        if #name == 0 or name == "Untitled" then
          name = "Game"
        end
        local pressed = love.window.showMessageBox (
          "Quit " .. name .. "?", "", {"OK", "Cancel"})
        if pressed == 1 then
          return
        end
      end
    end

    -- draw
    local width = love.graphics.getWidth ()
    local pad = 50
    local total_width = width - 3 * pad
    local error_width = math.floor (total_width/2)
    local source_width = total_width - error_width
    love.graphics.clear (love.graphics.getBackgroundColor ())
    love.graphics.setFont (error_font)
    love.graphics.printf (text, pad, pad, error_width, 'left')
    if source_text then
      love.graphics.setFont (source_font)
      love.graphics.printf (source_text, 2 * pad + error_width, pad, source_width, 'left')
    end
    love.graphics.present ()

    -- wait
    if love.timer then
      love.timer.sleep (1/20)
    end
	end
 
end

local errhand = love.errhand
function love.errhand (msg)
  local success, err = pcall (handle_error, msg)
  if not success then
    errhand (err .. '\n\noriginal error: ' .. tostring (msg))
  end
end

