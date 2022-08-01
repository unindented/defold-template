local component = require("druid.component")

---@class custom_slider : druid.base_component
local M = component.create("custom_slider")

local SCHEME = {
  INPUT = "input",
  HANDLE = "handle",
  TRACK = "track",
  TEXT = "text",
  VALUE = "value",
}

function M:init(template, value, callback)
  self:set_template(template)

  self.druid = self:get_druid()
  self.text = self.druid:new_lang_text(SCHEME.TEXT)
  self.value = self.druid:new_text(SCHEME.VALUE)
  self.slider = self.druid:new_slider(SCHEME.HANDLE, vmath.vector3(135, 0, 0), callback)
  self.slider:set_input_node(SCHEME.INPUT)

  self.slider.on_change_value:subscribe(function(_, value)
    self.value:set_to(tostring(math.ceil(value * 100)))
  end)

  self.slider:set(value)
end

return M
