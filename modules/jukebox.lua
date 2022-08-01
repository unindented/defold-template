local messages = require("modules.messages")
local settings = require("modules.settings")

local M = {}

M.current_music = nil

local GROUP_MASTER = hash("master")
local GROUP_MUSIC = hash("music")
local GROUP_EFFECTS = hash("effects")

local settings_map = {}
settings_map[GROUP_MASTER] = settings.MASTER_VOLUME
settings_map[GROUP_MUSIC] = settings.MUSIC_VOLUME
settings_map[GROUP_EFFECTS] = settings.EFFECTS_VOLUME

local function mute_if_music_playing()
  if sound.is_music_playing() then
    sound.set_group_gain("master", 0)
  end
end

local function window_callback(self, event, data)
  if event == window.WINDOW_EVENT_FOCUS_GAINED then
    mute_if_music_playing()
  end
end

local function get_volume(group)
  return sound.get_group_gain(group)
end

local function set_volume(group, value)
  sound.set_group_gain(group, value)
  settings.set(settings_map[group], value)
end

--- Initialize sound system.
function M.init()
  mute_if_music_playing()
  window.set_listener(window_callback)

  M.set_master_volume(settings.get(settings.MASTER_VOLUME))
  M.set_music_volume(settings.get(settings.MUSIC_VOLUME))
  M.set_effects_volume(settings.get(settings.EFFECTS_VOLUME))
end

--- Play background music.
--- @param sound_name string Sound name
function M.play_music(sound_name)
  if M.current_music ~= sound_name then
    M.stop_music()
    M.current_music = sound_name
    sound.play("main:/sounds#music_" .. M.current_music)
  end
end

--- Stop background music.
function M.stop_music()
  if M.current_music ~= nil then
    sound.stop("main:/sounds#music_" .. M.current_music)
  end
end

--- Play a sound effect.
--- @param sound_name string Sound name
function M.play_effect(sound_name)
  msg.post(
    "main:/sounds#sound_gate",
    messages.PLAY_GATED_SOUND,
    { soundcomponent = "main:/sounds#effect_" .. sound_name }
  )
end

--- Stop a sound effect.
--- @param sound_name string Sound name
function M.stop_effect(sound_name)
  sound.stop("main:/sounds#effect_" .. sound_name)
end

--- Return gain level for master group.
--- @return number
function M.get_master_volume()
  return get_volume(GROUP_MASTER)
end

--- Set gain level for master group.
--- @param value number Gain level
function M.set_master_volume(value)
  set_volume(GROUP_MASTER, value)
end

--- Return gain level for music group.
--- @return number
function M.get_music_volume()
  return get_volume(GROUP_MUSIC)
end

--- Set gain level for music group.
--- @param value number Gain level
function M.set_music_volume(value)
  set_volume(GROUP_MUSIC, value)
end

--- Return gain level for effects group.
--- @return number
function M.get_effects_volume()
  return get_volume(GROUP_EFFECTS)
end

--- Set gain level for effects group.
--- @param value number Gain level
function M.set_effects_volume(value)
  set_volume(GROUP_EFFECTS, value)
end

return M
