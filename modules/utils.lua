----------------------------------------------------------------------------------------------------
-- Utils: All other utils.
----------------------------------------------------------------------------------------------------

local M = {}

----------------------------------------------------------------------------------------------------
-- String utils
----------------------------------------------------------------------------------------------------

--- Returns true if a string begins with the characters of a specified string.
--- @param str string String to search
--- @param search string String to be searched for
--- @return boolean
function M.starts_with(str, search)
  return string.sub(str, 1, #search) == search
end

--- Returns true if a string ends with the characters of a specified string.
--- @param str string String to search
--- @param search string String to be searched for
--- @return boolean
function M.ends_with(str, search)
  return search == "" or string.sub(str, -#search) == search
end

----------------------------------------------------------------------------------------------------
-- Array utils
----------------------------------------------------------------------------------------------------

--- Return a new array populated with the results of calling a function on every element in the
--- original array.
--- @param array table Array
--- @param func function Function to apply
--- @return table
function M.map(array, func)
  local result = {}
  for i, v in ipairs(array) do
    result[i] = func(v)
  end
  return result
end

----------------------------------------------------------------------------------------------------
-- Table utils
----------------------------------------------------------------------------------------------------

--- Returns a new table with all the given tables merged together.
--- @param ... table Tables
--- @return table
function M.merge(...)
  local result = {}
  for i = 1, select("#", ...) do
    local t = select(i, ...)
    for k, v in pairs(t) do
      result[k] = v
    end
  end
  return result
end

----------------------------------------------------------------------------------------------------
-- Function utils
----------------------------------------------------------------------------------------------------

--- Return a function that ignores its first argument.
--- @param func function Function
--- @return function
function M.ignore_first(func)
  return function(_, ...)
    return func(...)
  end
end

local function cache_get(cache, params)
  local node = cache
  for i = 1, #params do
    node = node.children and node.children[params[i]]
    if not node then
      return nil
    end
  end
  return node.results
end

local function cache_put(cache, params, results)
  local node = cache
  local param
  for i = 1, #params do
    param = params[i]
    node.children = node.children or {}
    node.children[param] = node.children[param] or {}
    node = node.children[param]
  end
  node.results = results
end

--- Return a memoized version of a function
--- @param func function Function to memoize
--- @return function
function M.memoize(func, cache)
  cache = cache or {}
  return function(...)
    local params = { ... }
    local results = cache_get(cache, params)
    if not results then
      results = { func(...) }
      cache_put(cache, params, results)
    end
    return unpack(results)
  end
end

----------------------------------------------------------------------------------------------------
-- Misc utils
----------------------------------------------------------------------------------------------------

--- Return version information.
--- @return string
function M.version()
  local project_title = sys.get_config("project.title")
  local project_version = sys.get_config("project.version")
  local engine_info = sys.get_engine_info()
  local engine_version = engine_info.version
  local engine_sha1 = string.sub(engine_info.version_sha1, 1, 7)

  return project_title
    .. " v"
    .. project_version
    .. "\nDefold v"
    .. engine_version
    .. " ("
    .. engine_sha1
    .. ")"
end

--- Return whether this is a debug build.
--- @return boolean
function M.is_debug()
  local engine_info = sys.get_engine_info()
  return engine_info.is_debug
end

--- Return the platform name.
--- @return string
function M.platform()
  local sys_info = sys.get_sys_info()
  return sys_info.system_name
end

local function save_path(filename, xdg_varname, home_subdir)
  local appname = string.gsub(sys.get_config("project.title"), "%W", "")

  if M.platform() == "Linux" then
    local xdg_path = os.getenv(xdg_varname)
    local home_path = os.getenv("HOME")

    if xdg_path ~= nil then
      return xdg_path .. "/" .. appname .. "/" .. filename
    end
    if home_path ~= nil then
      return home_path .. "/" .. home_subdir .. "/" .. appname .. "/" .. filename
    end
  end

  return sys.get_save_file(appname, filename)
end

--- Return the config path for a file.
--- @param filename string File name
--- @return string
function M.config_path(filename)
  return save_path(filename, "XDG_CONFIG_HOME", ".config")
end

--- Return the data path for a file.
--- @param filename string File name
--- @return string
function M.data_path(filename)
  return save_path(filename, "XDG_DATA_HOME", ".local/share")
end

--- Return the state path for a file.
--- @param filename string File name
--- @return string
function M.state_path(filename)
  return save_path(filename, "XDG_STATE_HOME", ".local/state")
end

--- Quit.
function M.quit()
  if M.platform() ~= "HTML5" then
    sys.exit(0)
  end
end

return M
