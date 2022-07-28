local gooey = require("gooey.gooey")
local i18n = require("modules.i18n")
local sfx = require("modules.sfx")
local utils = require("modules.utils")
local colors = require("ui.colors")
local constants = require("ui.constants")

local M = gooey.create_theme()

local BUTTON_NORMAL = hash("button_normal")
local BUTTON_PRESSED = hash("button_pressed")

local CHECKBOX_NORMAL = hash("checkbox_normal")
local CHECKBOX_PRESSED = hash("checkbox_pressed")
local CHECKBOX_CHECKED = hash("checkbox_checked")

local RADIOBUTTON_NORMAL = hash("radiobutton_normal")
local RADIOBUTTON_PRESSED = hash("radiobutton_pressed")
local RADIOBUTTON_SELECTED = hash("radiobutton_selected")

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

local refresh_button_default = refresh_button(colors.palette.button, colors.palette.button_over)

local refresh_button_primary =
  refresh_button(colors.palette.button_primary, colors.palette.button_primary_over)

function M.button(node_id, config, action_id, action, fn)
  local primary = config and config.primary or false
  local silent = config and config.silent or false
  local text_transform = config and config.text_transform or string.utf8upper

  if not action then
    local button = gui.get_node(node_id .. "/button")
    local color = primary and colors.palette.button_primary or colors.palette.button
    gui.set_color(button, color)
    local text = gui.get_node(node_id .. "/text")
    i18n.set_text(text, nil, { text_transform = text_transform })
  end

  return gooey.button(
    node_id .. "/button",
    action_id,
    action,
    silent and fn or with_sound(fn),
    primary and refresh_button_primary or refresh_button_default
  )
end

local function refresh_checkbox(node_id)
  return function(checkbox)
    local box = gui.get_node(node_id .. "/box")

    if checkbox.over then
      gui.set_alpha(checkbox.node, 0.15)
      gui.set_color(box, colors.palette.checkbox_over)
    else
      gui.set_alpha(checkbox.node, 0)
      gui.set_color(box, colors.palette.checkbox)
    end

    if checkbox.pressed then
      gui.play_flipbook(box, CHECKBOX_PRESSED)
    elseif checkbox.checked then
      gui.play_flipbook(box, CHECKBOX_CHECKED)
    else
      gui.play_flipbook(box, CHECKBOX_NORMAL)
    end
  end
end

function M.checkbox(node_id, config, action_id, action, fn)
  if not action then
    local handle = gui.get_node(node_id .. "/box")
    gui.set_color(handle, colors.palette.checkbox)
    local text = gui.get_node(node_id .. "/text")
    i18n.set_text(text, nil, config)
  end

  return gooey.checkbox(node_id .. "/clickable", action_id, action, fn, refresh_checkbox(node_id))
end

local function refresh_radiobutton(node_id)
  return function(radiobutton)
    local box = gui.get_node(node_id .. "/box")

    if radiobutton.over then
      gui.set_alpha(radiobutton.node, 0.15)
      gui.set_color(box, colors.palette.radiobutton_over)
    else
      gui.set_alpha(radiobutton.node, 0)
      gui.set_color(box, colors.palette.radiobutton)
    end

    if radiobutton.pressed then
      gui.play_flipbook(box, RADIOBUTTON_PRESSED)
    elseif radiobutton.selected then
      gui.play_flipbook(box, RADIOBUTTON_SELECTED)
    else
      gui.play_flipbook(box, RADIOBUTTON_NORMAL)
    end
  end
end

function M.radiobutton(node_id, config, group_id, action_id, action, fn)
  if not action then
    local handle = gui.get_node(node_id .. "/box")
    gui.set_color(handle, colors.palette.radiobutton)
    local text = gui.get_node(node_id .. "/text")
    i18n.set_text(text, nil, config)
  end

  return gooey.radio(
    node_id .. "/clickable",
    group_id,
    action_id,
    action,
    fn,
    refresh_radiobutton(node_id)
  )
end

function M.radiogroup(group_id, action_id, action, fn)
  return gooey.radiogroup(group_id, action_id, action, fn)
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

function M.slider(node_id, config, action_id, action, fn)
  if not action then
    local handle = gui.get_node(node_id .. "/handle")
    gui.set_color(handle, colors.palette.slider)
    local bounds = gui.get_node(node_id .. "/bounds")
    gui.set_color(bounds, colors.palette.slider)
    local text = gui.get_node(node_id .. "/text")
    i18n.set_text(text, nil, config)
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

function M.heading(node_id, config)
  local text_transform = config and config.text_transform or string.utf8upper

  local text = gui.get_node(node_id .. "/text")
  i18n.set_text(text, nil, { text_transform = text_transform })
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
