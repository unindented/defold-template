local M = {}

M.settings = {}

M.REDUCE_MOTION = "reduce_motion"
M.DISABLE_SHADERS = "disable_shaders"
M.MASTER_VOLUME = "master_volume"
M.MUSIC_VOLUME = "music_volume"
M.EFFECTS_VOLUME = "effects_volume"
M.LANGUAGE = "language"

M.settings[M.REDUCE_MOTION] = false
M.settings[M.DISABLE_SHADERS] = false
M.settings[M.MASTER_VOLUME] = 1
M.settings[M.MUSIC_VOLUME] = 1
M.settings[M.EFFECTS_VOLUME] = 1
M.settings[M.LANGUAGE] = nil

function M.get(key)
  return M.settings[key]
end

function M.set(key, value)
  M.settings[key] = value
end

function M.setter(key)
  return function(value)
    M.set(key, value)
  end
end

return M
