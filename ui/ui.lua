local druid = require("druid.druid")
local hotkey = require("druid.extended.hotkey")
local i18n = require("modules.i18n")
local jukebox = require("modules.jukebox")
local utils = require("modules.utils")
local constants = require("ui.constants")
local styles = require("ui.styles.default")

local custom_button = require("ui.templates.button")
local custom_button_primary = require("ui.templates.button_primary")
local custom_button_primary_silent = require("ui.templates.button_primary_silent")
local custom_checkbox = require("ui.templates.checkbox")
local custom_debug = require("ui.templates.debug")
local custom_heading = require("ui.templates.heading")
local custom_radio = require("ui.templates.radio")
local custom_radio_group = require("ui.templates.radio_group")
local custom_slider = require("ui.templates.slider")
local custom_version = require("ui.templates.version")

local M = {}

local function sound_function(sound_name)
  jukebox.play_effect(sound_name)
end

local function text_function(id)
  local text = i18n.get_text(id)
  local should_uppercase = utils.starts_with(id, "button") or utils.starts_with(id, "heading")
  return should_uppercase and string.utf8upper(text) or text
end

--- Initialize UI systems.
function M.init()
  druid.set_default_style(styles)
  druid.set_sound_function(sound_function)
  druid.set_text_function(text_function)

  druid.register("hotkey", hotkey)
  druid.register("custom_button", custom_button)
  druid.register("custom_button_primary", custom_button_primary)
  druid.register("custom_button_primary_silent", custom_button_primary_silent)
  druid.register("custom_checkbox", custom_checkbox)
  druid.register("custom_debug", custom_debug)
  druid.register("custom_heading", custom_heading)
  druid.register("custom_radio", custom_radio)
  druid.register("custom_radio_group", custom_radio_group)
  druid.register("custom_slider", custom_slider)
  druid.register("custom_version", custom_version)
end

--- Set up UI with provided factory function.
--- @param context table Context (usually `self`)
--- @param factory function Factory function
--- @return druid_instance
function M.with(context, factory)
  local druid_instance = druid.new(context)
  factory(druid_instance)
  return druid_instance
end

function M.set_language(language)
  i18n.set_language(language)
  druid.on_language_change()
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
