local M = {}

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
