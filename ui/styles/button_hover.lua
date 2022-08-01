local M = {}

M["button"] = {
  DEFAULT_IMAGE = "background_default",
  HOVER_IMAGE = "background_hover",

  on_mouse_hover = function(self, node, state)
    local animation = state and M.button.HOVER_IMAGE or M.button.DEFAULT_IMAGE
    gui.play_flipbook(node, animation)
  end,
}

return M
