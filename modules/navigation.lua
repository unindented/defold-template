local monarch = require("monarch.monarch")
local transitions = require("monarch.transitions.gui")

local M = {}

local TRANSITION_SPEED_FAST = 0.1
local TRANSITION_SPEED_SLOW = 0.4

--- Create transition for use with screens.
--- @param node userdata Node to transition
--- @return table
function M.transition_screen(node)
  return transitions
    .create(node)
    .show_in(transitions.slide_out_right, gui.EASING_INCUBIC, TRANSITION_SPEED_SLOW, 0)
    .show_out(transitions.slide_in_left, gui.EASING_OUTCUBIC, TRANSITION_SPEED_SLOW, 0)
end

--- Create transition for use with popups.
--- @param node userdata Node to transition
--- @return table
function M.transition_popup(node)
  return transitions.fade_in_out(node, TRANSITION_SPEED_FAST, 0)
end

--- Show screen.
--- @param id string|hash - Id of the screen to show
function M.screen_show(id)
  monarch.show(id, { clear = true, sequential = true })
end

--- Replace screen.
--- @param id string|hash - Id of the screen to show
function M.screen_replace(id)
  monarch.replace(id, { sequential = true })
end

--- Show a popup that will render popup-on-popup screens that require a navigation stack.
--- @param id string|hash - Id of the screen to show
function M.popup_show(id)
  monarch.show(id, nil, { stack = {} })
end

--- Push a popup-on-popup screen onto the navigation stack.
--- @param id string|hash - Id of the screen to show
function M.popup_push(id)
  local current = monarch.top()
  local data = monarch.data(current)
  local stack = data.stack

  table.insert(stack, current)
  monarch.replace(id, nil, { stack = stack })
end

--- Pop a popup-on-popup screen from the navigation stack.
--- If the stack becomes empty, pop the original popup too.
function M.popup_pop()
  local current = monarch.top()
  local data = monarch.data(current)
  local stack = data.stack

  if #stack > 0 then
    -- if there's stuff in the stack, replace with it
    local id = table.remove(stack)
    monarch.replace(id, nil, { stack = stack })
  else
    -- if there's nothing left in the stack, pop the current popup...
    monarch.back()
    -- ... and the overlay
    monarch.back()
  end
end

--- Enable verbose logging.
function M.debug()
  monarch.debug()
end

--- Return navigation stack.
--- @return string
function M.dump_stack()
  return monarch.dump_stack()
end

return M
