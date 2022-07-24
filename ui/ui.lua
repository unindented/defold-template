local gooey = require("gooey.gooey")
local i18n = require("modules.i18n")
local sfx = require("modules.sfx")
local utils = require("modules.utils")
local colors = require("ui.colors")
local constants = require("ui.constants")

local M = gooey.create_theme()

local BUTTON_NORMAL = hash("button_normal")
local BUTTON_PRESSED = hash("button_pressed")

local function with_sound(fn)
  return function(element)
    sfx.play_effect("pluck")
    fn(element)
  end
end

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

local refresh_button_normal = refresh_button(colors.palette.button, colors.palette.button_over)

local refresh_button_primary =
  refresh_button(colors.palette.button_primary, colors.palette.button_primary_over)

function M.button(node_id, action_id, action, fn)
  if not action then
    local button = gui.get_node(node_id .. "/button")
    gui.set_color(button, colors.palette.button)
    local text = gui.get_node(node_id .. "/text")
    i18n.set_text(text, nil, string.utf8upper)
  end
  return gooey.button(
    node_id .. "/button",
    action_id,
    action,
    with_sound(fn),
    refresh_button_normal
  )
end

function M.button_primary(node_id, action_id, action, fn)
  if not action then
    local button = gui.get_node(node_id .. "/button")
    gui.set_color(button, colors.palette.button_primary)
    local text = gui.get_node(node_id .. "/text")
    i18n.set_text(text, nil, string.utf8upper)
  end
  return gooey.button(
    node_id .. "/button",
    action_id,
    action,
    with_sound(fn),
    refresh_button_primary
  )
end

local function refresh_slider(slider_id)
  return function(slider)
    local value = math.floor(100 - (slider.scroll.x * 100) + 0.5)
    gui.set_text(gui.get_node(slider_id .. "/value"), tostring(value))

    if slider.over then
      gui.set_color(slider.node, colors.palette.slider_over)
    else
      gui.set_color(slider.node, colors.palette.slider)
    end
  end
end

function M.slider(node_id, action_id, action, fn)
  if not action then
    local handle = gui.get_node(node_id .. "/handle")
    gui.set_color(handle, colors.palette.slider)
    local bounds = gui.get_node(node_id .. "/bounds")
    gui.set_color(bounds, colors.palette.slider)
    local text = gui.get_node(node_id .. "/text")
    i18n.set_text(text, nil, string.utf8upper)
  end
  return gooey.horizontal_scrollbar(
    node_id .. "/handle",
    node_id .. "/bounds",
    action_id,
    action,
    fn,
    refresh_slider(node_id)
  )
end

function M.heading(node_id)
  local text = gui.get_node(node_id .. "/text")
  i18n.set_text(text, nil, string.utf8upper)
end

function M.version(node_id)
  local text = gui.get_node(node_id .. "/text")
  gui.set_text(text, utils.version())
  gui.set_enabled(text, not utils.is_debug())
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
