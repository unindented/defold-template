local messages = require("modules.messages")

local M = {}

M.current_music = nil

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

--- Initialize sound system.
function M.init()
  mute_if_music_playing()
  window.set_listener(window_callback)
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

return M
