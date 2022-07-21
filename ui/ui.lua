local gooey = require("gooey.gooey")
local colors = require("modules.colors")
local i18n = require("modules.i18n")
local constants = require("ui.constants")

local M = gooey.create_theme()

local BUTTON_NORMAL = hash("button_normal")
local BUTTON_PRESSED = hash("button_pressed")

local function refresh_button(normal_color, over_color)
  return function(button)
    if button.over then
      gui.set_color(button.node, over_color)
    else
      gui.set_color(button.node, normal_color)
    end

    if button.pressed then
      gui.play_flipbook(button.node, BUTTON_PRESSED)
    else
      gui.play_flipbook(button.node, BUTTON_NORMAL)
    end
  end
end

local refresh_button_normal =
  refresh_button(colors.palette.button_default, colors.palette.button_default_over)

local refresh_button_primary =
  refresh_button(colors.palette.button_primary, colors.palette.button_primary_over)

function M.button(node_id, action_id, action, fn)
  if not action then
    local button = gui.get_node(node_id .. "/button")
    gui.set_color(button, colors.palette.button_default)
    local text = gui.get_node(node_id .. "/text")
    i18n.set_text(text, nil, string.utf8upper)
  end
  return gooey.button(node_id .. "/button", action_id, action, fn, refresh_button_normal)
end

function M.button_primary(node_id, action_id, action, fn)
  if not action then
    local button = gui.get_node(node_id .. "/button")
    gui.set_color(button, colors.palette.button_primary)
    local text = gui.get_node(node_id .. "/text")
    i18n.set_text(text, nil, string.utf8upper)
  end
  return gooey.button(node_id .. "/button", action_id, action, fn, refresh_button_primary)
end

function M.heading(node_id)
  local text = gui.get_node(node_id .. "/text")
  i18n.set_text(text, nil, string.utf8upper)
end

function M.acquire_input()
  gooey.acquire_input()
end

function M.set_render_order_popup_overlay()
  gui.set_render_order(constants.GUI_ORDER_POPUP_OVERLAY)
end

function M.set_render_order_popup_content()
  gui.set_render_order(constants.GUI_ORDER_POPUP_CONTENT)
end

function M.set_render_order_fader()
  gui.set_render_order(constants.GUI_ORDER_FADER)
end

function M.set_render_order_debug()
  gui.set_render_order(constants.GUI_ORDER_DEBUG)
end

return M
