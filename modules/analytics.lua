----------------------------------------------------------------------------------------------------
-- Analytics: Screen, event, and error/crash reporting.
----------------------------------------------------------------------------------------------------

local jason = require("modules.jason")
local log = require("modules.log")
local sticky = require("modules.sticky")
local user_agent = require("modules.user_agent")
local utils = require("modules.utils")

local M = {}

M.meta = nil
M.timeout = 3
M.max_retries = 2
M.autodispatch_timer = 0
M.autodispatch_interval = 1

----------------------------------------------------------------------------------------------------
-- Internal API
----------------------------------------------------------------------------------------------------

local FILENAME = "analytics"
local QUEUE = "queue"

local defaults = {
  [QUEUE] = {},
}

--- Return the queue of items to report.
--- @return table
local function get_queue()
  return sticky.get(FILENAME, QUEUE)
end

--- Return some metadata included in all requests.
--- @return table
local get_meta = utils.memoize(function()
  local dsn = sys.get_config("umami.dsn")
  local website_id = sys.get_config("umami.website_id")

  local screen_size = sys.get_config("display.width") .. "x" .. sys.get_config("display.height")

  local project_title = sys.get_config("project.title")
  local project_version = sys.get_config("project.version")
  local appname = project_title .. " " .. project_version
  local hostname = appname:lower():gsub("%W+", "-") .. ".com"

  local engine_info = sys.get_engine_info()
  local engine_version = engine_info.version

  local sys_info = sys.get_sys_info()
  local language = sys_info.device_language

  return {
    dsn = dsn,
    engine_version = engine_version,
    hostname = hostname,
    language = language,
    screen = screen_size,
    project_version = project_version,
    website = website_id,
  }
end)

--- Make a request to post an item from the queue.
--- @param queue table Queue of items
---@param item table Item to post
---@param max_retries number Max retries
---@param timeout number Request timeout
local function post_item(queue, item, max_retries, timeout)
  local function callback(self, id, response)
    local bad_response = response.status < 200 or response.status >= 300
    if bad_response and item.retries < max_retries then
      log.warn("dispatch failed: " .. response.status)
      log.warn("retrying item: " .. item.type)
      item.retries = item.retries + 1
      table.insert(queue, item)
    end
  end

  local headers = {
    ["Content-Type"] = "application/json",
    ["User-Agent"] = user_agent.get(),
  }
  local meta = get_meta()
  local payload = item.payload
  local post_data = jason.encode({
    type = item.type,
    payload = {
      event_name = payload.event_name,
      event_data = payload.event_data,
      hostname = meta.hostname,
      language = meta.language,
      screen = meta.screen,
      url = "/"
        .. (payload.url or "")
        .. "?project_version="
        .. meta.project_version
        .. "&engine_version="
        .. meta.engine_version,
      website = meta.website,
    },
  })
  local http_options = { timeout = timeout }

  log.debug("dispatching item: " .. item.type)
  http.request(meta.dsn .. "/api/collect", "POST", callback, headers, post_data, http_options)
end

----------------------------------------------------------------------------------------------------
-- Public API
----------------------------------------------------------------------------------------------------

--- Load saved items, and enable error/crash reporting.
function M.init()
  sticky.load(FILENAME, defaults)
  M.enable_error_crash_reporting()
end

--- Save items before quitting.
function M.final()
  sticky.save(FILENAME)
end

--- Dispatch and save items on an interval.
--- @param dt number Delta time
function M.update(dt)
  sticky.autosave(FILENAME, dt)
  M.autodispatch(dt)
end

--- Report screen view.
--- @param screen_name string Screen name
function M.screen(screen_name)
  M.report("pageview", {
    url = screen_name,
  })
end

--- Report event.
--- @param event_name string Event name
--- @param event_data table Event data
--- @param screen_name string? Screen name
function M.event(event_name, event_data, screen_name)
  M.report("event", {
    event_name = event_name,
    event_data = event_data,
    url = screen_name,
  })
end

--- Report error.
--- @param message string Error message
function M.error(message)
  M.event("error", { message = message })
end

--- Report crash.
--- @param data string Crash data
function M.crash(data)
  M.event("crash", { data = data })
end

--- Report item.
--- @param type string Item type
--- @param payload table Item payload
function M.report(type, payload)
  table.insert(get_queue(), {
    type = type,
    payload = payload,
    retries = 0,
  })
  sticky.set(FILENAME, QUEUE, get_queue())
end

--- Dispatch first queued item.
function M.dispatch()
  local queue = get_queue()

  if #queue == 0 then
    return
  end

  local item = table.remove(queue, 1)
  post_item(queue, item, M.max_retries, M.timeout)
end

--- Auto-dispatch items if enough time has passed.
--- @param dt number Delta time
function M.autodispatch(dt)
  M.autodispatch_timer = M.autodispatch_timer + dt

  if M.autodispatch_timer >= M.autodispatch_interval then
    M.autodispatch_timer = M.autodispatch_timer - M.autodispatch_interval
    M.dispatch()
  end
end

--- Enable error/crash reporting.
function M.enable_error_crash_reporting()
  sys.set_error_handler(function(source, message, traceback)
    local full_message = message .. "\n" .. traceback
    M.error(full_message)
    log.error(full_message)
  end)

  local handle = crash and crash.load_previous()
  if handle ~= nil then
    local full_message = crash.get_extra_data(handle)
    M.crash(full_message)
    log.fatal(full_message)
    crash.release(handle)
  end
end

return M
