local component = require("druid.component")
local styles = require("ui.styles.button_hover")

---@class custom_checkbox : druid.base_component
local M = component.create("custom_checkbox")

local SCHEME = {
  INPUT = "input",
  FRONT = "front",
  TEXT = "text",
}

function M:init(template, state, callback)
  self:set_template(template)

  self.druid = self:get_druid()
  self.text = self.druid:new_lang_text(SCHEME.TEXT)
  self.checkbox = self.druid:new_checkbox(SCHEME.FRONT, callback, SCHEME.INPUT, state)
  self.checkbox.button:set_style(styles)

  -- apply hover style on init, so that the button picks the right color
  self.checkbox.button.style.on_mouse_hover(
    self.checkbox.button,
    self.checkbox.button.anim_node,
    false
  )
end

function M:set_state(state, is_silent, is_instant)
  return self.checkbox:set_state(state, is_silent, is_instant)
end

function M:get_state()
  return self.checkbox:get_state()
end

return M
