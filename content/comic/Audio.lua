import 'util'
import 'comic'

local Audio = class 'Audio'

function Audio.get:sounds()
  return self.context.resources.sounds
end

function Audio:init(parent_ctx)
  self.context = parent_ctx:new(self)

  -- music properties
  self.music_sound = false
  self.music_fade_ratio = 0
  self.next_music_sound = false
  self.last_music_index = 0
end

function Audio:play_next_music()
  -- play random music
  local index = 0
  local music_tracks = self.context.resources.sounds.ambient
  
  if #music_tracks > 1 then
    while index == 0 or index == self.last_music_index do
      index = help.random_int(1, #music_tracks)
    end
  else
    index = 1
  end

  self.last_music_index = index
  self.context.audio:play_music(music_tracks[index])
end

function Audio.listens:update(dt)
  self:update_music(dt)
end

-- update fading on music
function Audio:update_music(dt)
  local music_volume = 0

  if self.music_sound then
    music_volume = self.music_sound.source:getVolume()

    local dir = self.next_music_sound and -1 or 1
    local fade_speed = 0.2

    self.music_fade_ratio = help.clamp(0, self.music_fade_ratio + dir * dt/fade_speed, 1)
    music_volume = self.music_fade_ratio * self.music_sound.volume
    self.music_sound.source:setVolume(music_volume)
  end

  if self.next_music_sound and music_volume == 0 then
    self:start_next_music()
  end
end

function Audio:start_next_music()
  assert(self.next_music_sound, 'a next music sound must exist')
  
  --print('start next music')
  if self.music_sound then
    self.music_sound.source:stop()
  end

  self.music_sound = self.next_music_sound
  self.next_music_sound = false
  self.music_fade_ratio = 0
  
  self.music_sound.source:stop()
  local duration = self.music_sound.source:getDuration ()
  
  if duration > 0 then
    self.music_sound.source:seek (math.random () * duration)
  end

  self.music_sound.source:play()
end

-- returns a cloned sound source from:
  -- a given sound object
  -- a random sound object from a given list
function Audio:get_source(sound_list)
  local sound = false
  if sound_list.is_sound then
    sound = sound_list
  else
    -- choose a random sound from a list
    while not sound do
      local index = help.random_int(1, #sound_list)
      sound = sound_list[index]
      
      -- if the sound was last played then choose a different one
      if sound == sound_list.last_played and #sound_list > 1 then
        sound = false
      else
        sound_list.last_played = sound
      end
    end
  end

  local source =  sound.source:clone()
  source:setVolume(sound.volume)
  source:setPitch(sound.pitch)

  return source
end

-- plays a cloned sound source
function Audio:play_sound(sound_list)
  local source = self:get_source(sound_list)
  source:play()
end

-- queues music to be played when the last music fades out 
function Audio:play_music(sound)
  if sound == self.next_music_sound then
    -- song is already queued
    return
  else
    if not self.next_music_sound and sound == self.music_sound then
      -- song already playing
      return
    end
  end

  self.next_music_sound = sound
  self.next_music_sound.source:setPitch(self.next_music_sound.pitch)
  self.next_music_sound.source:setLooping(true)

  -- start with 0 volume 
  self.next_music_sound.source:setVolume(0)
end

return Audio
