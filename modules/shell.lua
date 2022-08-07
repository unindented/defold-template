local M = {}

--- Return true if app is fullscreen.
--- @return boolean
function M.is_fullscreen()
  return defos.is_fullscreen()
end

--- Set app to fullscreen.
--- @param fullscreen boolean Fullscreen
function M.set_fullscreen(fullscreen)
  return defos.set_fullscreen(fullscreen)
end

return M
