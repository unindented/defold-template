local component = require("druid.component")

---@class custom_heading : druid.base_component
local M = component.create("custom_heading")

local SCHEME = {
  TEXT = "text",
}

function M:init(template)
  self:set_template(template)

  self.druid = self:get_druid()
  self.text = self.druid:new_lang_text(SCHEME.TEXT)
end

return M
