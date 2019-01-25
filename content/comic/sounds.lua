local audio_path = 'data/audio/'

local function new_sound(path, volume, pitch)
  return {
    volume = volume or 1,
    pitch = pitch or 1,
    source = love.audio.newSource (audio_path .. path, 'static'),
    is_sound = true
  }
end

local function new_music(path, volume, pitch)
  local mode = (love.system.getOS () == 'iOS') and 'static' or 'stream'
  return {
    volume = volume or 1,
    pitch = pitch or 1,
    source = love.audio.newSource (audio_path .. path, mode),
    is_sound = true
  }
end

local sounds =
{
  -- ambient
  ambient = {
    new_music('rain.mp3', 1, 1),
    },

  -- sfx
  notes = {
    new_sound('c1.wav', 1, 1),
    new_sound('c4.wav', 1, 1),
    new_sound('g24.wav', 1, 1),

  },
}

return sounds
