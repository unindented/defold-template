local settings = require("druid.system.settings")
local colors = require("ui.colors")

local M = {}

M["button"] = {
  DEFAULT_IMAGE = "button_default",
  PRESSED_IMAGE = "button_pressed",
  CLICK_SOUND = "pluck",

  on_mouse_hover = function(self, node, state)
    local color = state and colors.BUTTON_PRIMARY_HOVER or colors.BUTTON_PRIMARY
    gui.set_color(node, color)
  end,

  on_hover = function(self, node, state)
    local animation = state and M.button.PRESSED_IMAGE or M.button.DEFAULT_IMAGE
    gui.play_flipbook(node, animation)
  end,

  on_click = function(self, node)
    settings.play_sound(M.button.CLICK_SOUND)
  end,

  on_click_disabled = function(self, node)
    settings.play_sound(M.button.CLICK_SOUND)
  end,
}

return M
