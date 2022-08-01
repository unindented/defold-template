local dcolors = require("dcolors.dcolors")

local BUTTON_COLOR = dcolors.hex_to_rgba("505050FF")
local BUTTON_HOVER_COLOR = dcolors.hex_to_rgba("616161FF")
local BUTTON_PRIMARY_COLOR = dcolors.hex_to_rgba("753259FF")
local BUTTON_PRIMARY_HOVER_COLOR = dcolors.hex_to_rgba("8D3C6BFF")

dcolors.add_palette("default")
dcolors.add_color("default", "button", BUTTON_COLOR)
dcolors.add_color("default", "button_hover", BUTTON_HOVER_COLOR)
dcolors.add_color("default", "button_primary", BUTTON_PRIMARY_COLOR)
dcolors.add_color("default", "button_primary_hover", BUTTON_PRIMARY_HOVER_COLOR)

return dcolors
