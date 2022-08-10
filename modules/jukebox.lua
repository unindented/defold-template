----------------------------------------------------------------------------------------------------
-- Jukebox: Sound module.
----------------------------------------------------------------------------------------------------

local log = require("modules.log")
local messages = require("modules.messages")
local settings = require("modules.settings")

local M = {}

M.current_music = nil

----------------------------------------------------------------------------------------------------
-- Internal API
----------------------------------------------------------------------------------------------------

local GROUP_MASTER = hash("master")
local GROUP_MUSIC = hash("music")
local GROUP_EFFECTS = hash("effects")

local function mute_if_music_playing()
  if sound.is_music_playing() then
    log.debug("music is playing, muting master")
    sound.set_group_gain("master", 0)
  end
end

local function window_callback(self, event, data)
  if event == window.WINDOW_EVENT_FOCUS_GAINED then
    mute_if_music_playing()
  end
end

----------------------------------------------------------------------------------------------------
-- Public API
----------------------------------------------------------------------------------------------------

--- Initialize sound system by reading volume values from settings.
--- If music is playing on iOS or Android, mute master.
--- @see https://defold.com/ref/sound/#sound.is_music_playing
function M.init()
  M.set_master_volume(settings.get_master_volume())
  M.set_music_volume(settings.get_music_volume())
  M.set_effects_volume(settings.get_effects_volume())

  mute_if_music_playing()
  window.set_listener(window_callback)
end

--- Play new background music. If the music to play is the same as the current one, do nothing.
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

--- Play a sound effect, with gating.
--- @see https://defold.com/manuals/sound/#gating-sounds
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
  return sound.get_group_gain(GROUP_MASTER)
end

--- Set gain level for master group.
--- @param value number Gain level
function M.set_master_volume(value)
  sound.set_group_gain(GROUP_MASTER, value)
  settings.set_master_volume(value)
end

--- Return gain level for music group.
--- @return number
function M.get_music_volume()
  return sound.get_group_gain(GROUP_MUSIC)
end

--- Set gain level for music group.
--- @param value number Gain level
function M.set_music_volume(value)
  sound.set_group_gain(GROUP_MUSIC, value)
  settings.set_music_volume(value)
end

--- Return gain level for effects group.
--- @return number
function M.get_effects_volume()
  return sound.get_group_gain(GROUP_EFFECTS)
end

--- Set gain level for effects group.
--- @param value number Gain level
function M.set_effects_volume(value)
  sound.set_group_gain(GROUP_EFFECTS, value)
  settings.set_effects_volume(value)
end

return M
