----------------------------------------------------------------------------------------------------
-- Settings: Persisted user settings.
----------------------------------------------------------------------------------------------------

local sticky = require("modules.sticky")

local M = {}

----------------------------------------------------------------------------------------------------
-- Internal API
----------------------------------------------------------------------------------------------------

local FILENAME = "settings"
local VERSION = "__version__"
local FULLSCREEN = "fullscreen"
local REDUCE_MOTION = "reduce_motion"
local DISABLE_SHADERS = "disable_shaders"
local MASTER_VOLUME = "master_volume"
local MUSIC_VOLUME = "music_volume"
local EFFECTS_VOLUME = "effects_volume"
local LANGUAGE = "language"

local defaults = {
  [VERSION] = "1",
  [FULLSCREEN] = false,
  [REDUCE_MOTION] = false,
  [DISABLE_SHADERS] = false,
  [MASTER_VOLUME] = 1,
  [MUSIC_VOLUME] = 1,
  [EFFECTS_VOLUME] = 1,
  [LANGUAGE] = nil,
}

--- Return the value for a certain key.
--- @param key string Key
--- @return any
local function get(key)
  return sticky.get(FILENAME, key)
end

--- Set the value for a certain key.
--- @param key string Key
--- @param value any New value
--- @return boolean
local function set(key, value)
  return sticky.set(FILENAME, key, value)
end

----------------------------------------------------------------------------------------------------
-- Public API
----------------------------------------------------------------------------------------------------

function M.init()
  sticky.load(FILENAME, defaults)
end

function M.final()
  sticky.save(FILENAME)
end

function M.update(dt)
  sticky.autosave(FILENAME, dt)
end

function M.get_fullscreen()
  return get(FULLSCREEN)
end

function M.set_fullscreen(fullscreen)
  return set(FULLSCREEN, fullscreen)
end

function M.get_reduce_motion()
  return get(REDUCE_MOTION)
end

function M.set_reduce_motion(reduce_motion)
  return set(REDUCE_MOTION, reduce_motion)
end

function M.get_disable_shaders()
  return get(DISABLE_SHADERS)
end

function M.set_disable_shaders(disable_shaders)
  return set(DISABLE_SHADERS, disable_shaders)
end

--- Return the master volume (0 to 1).
--- @return number
function M.get_master_volume()
  return get(MASTER_VOLUME)
end

--- Set the master volume (0 to 1).
--- @param volume number Volume
--- @return boolean
function M.set_master_volume(volume)
  return set(MASTER_VOLUME, volume)
end

--- Return the music volume (0 to 1).
--- @return number
function M.get_music_volume()
  return get(MUSIC_VOLUME)
end

--- Set the music volume (0 to 1).
--- @param volume number Volume
--- @return boolean
function M.set_music_volume(volume)
  return set(MUSIC_VOLUME, volume)
end

--- Return the effects volume (0 to 1).
--- @return number
function M.get_effects_volume()
  return get(EFFECTS_VOLUME)
end

--- Set the effects volume (0 to 1).
--- @param volume number Volume
--- @return boolean
function M.set_effects_volume(volume)
  return set(EFFECTS_VOLUME, volume)
end

--- Return the current language.
--- @return string
function M.get_language()
  return get(LANGUAGE)
end

--- Set the current language.
--- @param language string Language
--- @return boolean
function M.set_language(language)
  return set(LANGUAGE, language)
end

return M
