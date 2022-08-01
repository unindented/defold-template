local component = require("druid.component")
local utils = require("modules.utils")

---@class custom_version : druid.base_component
local M = component.create("custom_version")

local SCHEME = {
  TEXT = "text",
}

function M:init(template)
  self:set_template(template)

  self.druid = self:get_druid()
  self.is_enabled = not utils.is_debug()
  self.get_text = utils.version
  self.text = self.druid:new_text(SCHEME.TEXT, self.get_text())

  gui.set_enabled(self.text.node, self.is_enabled)
end

return M
