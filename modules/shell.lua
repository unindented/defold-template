----------------------------------------------------------------------------------------------------
-- Shell: Utils for dealing with the OS window.
----------------------------------------------------------------------------------------------------

local settings = require("modules.settings")

local M = {}

----------------------------------------------------------------------------------------------------
-- Public API
----------------------------------------------------------------------------------------------------

--- Initialize shell.
function M.init()
  M.set_fullscreen(settings.get_fullscreen())
end

--- Return true if app is fullscreen.
--- @return boolean
function M.is_fullscreen()
  return defos.is_fullscreen()
end

--- Set app to fullscreen.
--- @param fullscreen boolean Fullscreen
function M.set_fullscreen(fullscreen)
  defos.set_fullscreen(fullscreen)
  settings.set_fullscreen(fullscreen)
end

return M
