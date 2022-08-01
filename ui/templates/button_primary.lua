local component = require("druid.component")
local styles = require("ui.styles.button_primary")

---@class custom_button_primary : druid.base_component
local M = component.create("custom_button_primary")

local SCHEME = {
  BUTTON = "button",
  TEXT = "text",
}

function M:init(template, callback, params, anim_node)
  self:set_template(template)

  self.druid = self:get_druid()
  self.text = self.druid:new_lang_text(SCHEME.TEXT)
  self.button = self.druid:new_button(SCHEME.BUTTON, callback, params, anim_node)
  self.button:set_style(styles)

  -- apply hover style on init, so that the button picks the right color
  self.button.style.on_mouse_hover(self.button, self.button.anim_node, false)
end

return M
