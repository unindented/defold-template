local component = require("druid.component")
local utils = require("modules.utils")

---@class custom_debug : druid.base_component
local M = component.create("custom_debug")

local SCHEME = {
  TEXT = "text",
}

function M:init(template, get_text)
  self:set_template(template)

  self.druid = self:get_druid()
  self.is_enabled = utils.is_debug()
  self.get_text = get_text
  self.text = self.druid:new_text(SCHEME.TEXT, self.get_text())

  gui.set_enabled(self.text.node, self.is_enabled)
end

function M:update(dt)
  if self.is_enabled then
    self.text:set_to(self.get_text())
  end
end

return M
