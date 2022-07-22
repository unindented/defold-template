local dcolors = require("dcolors.dcolors")

local BUTTON_COLOR = dcolors.hex_to_rgba("505050FF")
local BUTTON_OVER_COLOR = dcolors.hex_to_rgba("616161FF")
local BUTTON_PRIMARY_COLOR = dcolors.hex_to_rgba("753259FF")
local BUTTON_PRIMARY_OVER_COLOR = dcolors.hex_to_rgba("8D3C6BFF")
local SLIDER_COLOR = dcolors.hex_to_rgba("808080FF")
local SLIDER_OVER_COLOR = dcolors.hex_to_rgba("8C8C8CFF")

dcolors.add_palette("default")
dcolors.add_color("default", "button", BUTTON_COLOR)
dcolors.add_color("default", "button_over", BUTTON_OVER_COLOR)
dcolors.add_color("default", "button_primary", BUTTON_PRIMARY_COLOR)
dcolors.add_color("default", "button_primary_over", BUTTON_PRIMARY_OVER_COLOR)
dcolors.add_color("default", "slider", SLIDER_COLOR)
dcolors.add_color("default", "slider_over", SLIDER_OVER_COLOR)

return dcolors
