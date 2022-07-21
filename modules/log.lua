local log = require("log.log")

local M = {}

function M.init()
  log.set_appname(sys.get_config("project.title"))
  log.toggle_print()
end

--- Log a trace message.
--- @param message string Message
--- @param tag (string|nil) Tag
function M.t(message, tag)
  return log.t(message, tag)
end

--- Log a debug message.
--- @param message string Message
--- @param tag (string|nil) Tag
function M.d(message, tag)
  return log.d(message, tag)
end

--- Log an info message.
--- @param message string Message
--- @param tag (string|nil) Tag
function M.i(message, tag)
  return log.i(message, tag)
end

--- Log a warning message.
--- @param message string Message
--- @param tag (string|nil) Tag
function M.w(message, tag)
  return log.w(message, tag)
end

--- Log an error message.
--- @param message string Message
--- @param tag (string|nil) Tag
function M.e(message, tag)
  return log.e(message, tag)
end

return M
