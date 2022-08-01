local colors = require("ui.colors")

local M = {}

M["button"] = {
  DEFAULT_IMAGE = "button_default",
  PRESSED_IMAGE = "button_pressed",

  on_mouse_hover = function(self, node, state)
    local color = state and colors.palette.button_primary_hover or colors.palette.button_primary
    gui.set_color(node, color)
  end,

  on_hover = function(self, node, state)
    local animation = state and M.button.PRESSED_IMAGE or M.button.DEFAULT_IMAGE
    gui.play_flipbook(node, animation)
  end,
}

return M
