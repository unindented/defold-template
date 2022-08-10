----------------------------------------------------------------------------------------------------
-- Log: Logging module.
----------------------------------------------------------------------------------------------------

local utils = require("modules.utils")

local M = {}

M.DEBUG = 1
M.INFO = 2
M.WARN = 3
M.ERROR = 4
M.FATAL = 5

M.level = nil
M.should_print = true

----------------------------------------------------------------------------------------------------
-- Internal API
----------------------------------------------------------------------------------------------------

local level_names = {
  "DEBUG",
  "INFO ",
  "WARN ",
  "ERROR",
  "FATAL",
}

local function get_debug_info()
  if debug == nil then
    return
  end

  local debug_info = debug.getinfo(4, "Sl")
  return debug_info.short_src .. ":" .. debug_info.currentline .. ": "
end

local function get_line(message, level, datetime)
  local head = datetime .. " - " .. level_names[level] .. " - "
  local body = get_debug_info() or ""
  return head .. body .. message
end

----------------------------------------------------------------------------------------------------
-- Public API
----------------------------------------------------------------------------------------------------

--- Initialize logging system.
function M.init()
  local is_debug = utils.is_debug()
  M.set_level(is_debug and M.DEBUG or M.WARN)
  M.set_print(is_debug or utils.platform() == "HTML5")
end

--- Set the log level.
--- @param level number Log level
function M.set_level(level)
  M.level = level
end

--- Set whether logs should be printed.
--- @param should_print boolean Whether logs should be printed
function M.set_print(should_print)
  M.should_print = should_print
end

--- Log a debug message.
--- @param message string Message
function M.debug(message)
  return M.log(message, M.DEBUG)
end

--- Log an info message.
--- @param message string Message
function M.info(message)
  return M.log(message, M.INFO)
end

--- Log a warning message.
--- @param message string Message
function M.warn(message)
  return M.log(message, M.WARN)
end

--- Log an error message.
--- @param message string Message
function M.error(message)
  return M.log(message, M.ERROR)
end

--- Log a critical message.
--- @param message string Message
function M.fatal(message)
  return M.log(message, M.FATAL)
end

function M.log(message, level)
  if level < M.level then
    return nil
  end

  local timestamp = os.time()
  local date = os.date("%Y-%m-%d", timestamp)
  local datetime = os.date("%Y-%m-%d %H:%M:%S", timestamp)

  local line = get_line(message, level, datetime)

  if M.should_print then
    print(line)
  end

  if utils.platform() == "HTML5" then
    return nil
  end

  local filename = date .. ".log"
  local path = utils.state_path(filename)
  local file, err = io.open(path, "a")

  if file == nil or err then
    print("could not open file '" .. path .. "': " .. err)
    return nil, err
  end

  file:write(line, "\n")
  file:close()

  return path
end

return M
