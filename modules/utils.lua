local M = {}

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

--- Return a function that ignores its first argument.
--- @param func function Function
--- @return function
function M.ignore_self(func)
  return function(self, ...)
    return func(...)
  end
end

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

--- Quit.
function M.quit()
  local sys_info = sys.get_sys_info()
  if sys_info.system_name ~= "HTML5" then
    sys.exit(0)
  end
end

return M
