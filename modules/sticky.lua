----------------------------------------------------------------------------------------------------
-- Sticky: Persist settings and other user data.
----------------------------------------------------------------------------------------------------

local log = require("modules.log")
local utils = require("modules.utils")

local M = {}

M.files = {}

----------------------------------------------------------------------------------------------------
-- Internal API
----------------------------------------------------------------------------------------------------

local function safe_save(filename, data)
  local path = utils.data_path(filename)

  log.debug("saving file '" .. filename .. "'")

  local ok, err = pcall(function()
    if not sys.save(path, data) then
      error("data could not be saved")
    end
  end)

  if not ok then
    log.error("file '" .. filename .. "' could not be saved to path '" .. path .. "': " .. err)
  end

  return ok, err
end

local function safe_load(filename, retrying)
  local path = utils.data_path(filename)

  log.debug("loading file '" .. filename .. "'")

  local ok, data_or_err = pcall(function()
    return sys.load(path)
  end)

  if ok then
    if not retrying then
      safe_save(filename .. ".bak", data_or_err) -- create backup, just in case
    end
  else
    log.error("file '" .. filename .. "' is corrupt: " .. data_or_err)
    if not retrying then
      ok, data_or_err = safe_load(filename .. ".bak", true)
    end
  end

  return ok, data_or_err
end

----------------------------------------------------------------------------------------------------
-- Public API
----------------------------------------------------------------------------------------------------

--- Load file. If file doesn't exist, or can't be loaded, load defaults.
--- @param filename string File name
--- @param defaults table Defaults
--- @return boolean
--- @return any
function M.load(filename, defaults)
  defaults = defaults or {}

  local loaded, contents = safe_load(filename)
  local is_empty = not loaded or next(contents) == nil
  contents = is_empty and defaults or utils.merge(defaults, contents)

  M.files[filename] = {
    changed = false,
    contents = contents,
  }

  return loaded, contents
end

--- Save file if it has changes.
--- @param filename string File name
--- @param force boolean Force save
--- @return boolean
--- @return any
function M.save(filename, force)
  force = force or false

  if not M.is_loaded(filename) then
    log.error("file '" .. filename .. "' is not loaded")
    return false, nil
  end

  if not M.files[filename].changed and not force then
    log.debug("file '" .. filename .. "' is not changed; use force flag if needed")
    return false, nil
  end

  local saved, err = safe_save(filename, M.files[filename].contents)

  M.files[filename].changed = not saved

  return saved, err
end

--- Return the value for a key in a loaded file.
--- @param filename string File name
--- @param key string Key
--- @return any
function M.get(filename, key)
  if not M.is_loaded(filename) then
    log.error("file '" .. filename .. "' is not loaded")
    return nil
  end

  local file = M.files[filename]
  return file.contents[key]
end

--- Set the value for a key in a loaded file.
--- @param filename string File name
--- @param key string Key
--- @param value any Value
--- @return boolean
function M.set(filename, key, value)
  if not M.is_loaded(filename) then
    log.error("file '" .. filename .. "' is not loaded")
    return false
  end

  local file = M.files[filename]
  file.contents[key] = value
  file.changed = true

  return true
end

--- Return true if a file is already loaded in memory.
--- @param filename string File name
--- @return boolean
function M.is_loaded(filename)
  return M.files[filename] ~= nil
end

--- Clear all cached content.
function M.reset()
  M.files = {}
end

return M
