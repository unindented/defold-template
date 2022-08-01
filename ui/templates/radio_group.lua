local component = require("druid.component")
local Event = require("druid.event")

---@class custom_radio_group : druid.base_component
local M = component.create("custom_radio_group")

local function on_radio_click(self, index, is_instant)
  for i = 1, #self.radios do
    self.radios[i]:set_state(i == index, true, is_instant)
  end

  self.on_radio_click:trigger(self:get_context(), index)
end

function M.init(self, templates, states, callback)
  self.druid = self:get_druid()
  self.radios = {}

  self.on_radio_click = Event(callback)

  for i = 1, #templates do
    local checkbox = self.druid:new_custom_checkbox(templates[i], states[i], function()
      on_radio_click(self, i)
    end)

    table.insert(self.radios, checkbox)
  end
end

function M.set_state(self, index, is_instant)
  on_radio_click(self, index, is_instant)
end

function M.get_state(self)
  local result = -1

  for i = 1, #self.radios do
    if self.radios[i]:get_state() then
      result = i
      break
    end
  end

  return result
end

return M
