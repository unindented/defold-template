local dcolors = require("dcolors.dcolors")

local BUTTON_DEFAULT_COLOR = dcolors.hex_to_rgba("505050FF")
local BUTTON_DEFAULT_OVER_COLOR = dcolors.hex_to_rgba("616161FF")
local BUTTON_PRIMARY_COLOR = dcolors.hex_to_rgba("753259FF")
local BUTTON_PRIMARY_OVER_COLOR = dcolors.hex_to_rgba("8D3C6BFF")

dcolors.add_palette("default")
dcolors.add_color("default", "button_default", BUTTON_DEFAULT_COLOR)
dcolors.add_color("default", "button_default_over", BUTTON_DEFAULT_OVER_COLOR)
dcolors.add_color("default", "button_primary", BUTTON_PRIMARY_COLOR)
dcolors.add_color("default", "button_primary_over", BUTTON_PRIMARY_OVER_COLOR)

return dcolors
