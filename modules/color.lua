local M = {}

--- Convert a hex color to RGBA.
--- @param hex_color string CSV to parse.
--- @return vector4
function M.hex_to_rgba(hex_color)
  local r = tonumber("0x" .. string.sub(hex_color, 1, 2)) / 255
  local g = tonumber("0x" .. string.sub(hex_color, 3, 4)) / 255
  local b = tonumber("0x" .. string.sub(hex_color, 5, 6)) / 255
  local a = tonumber("0x" .. string.sub(hex_color, 7, 8)) / 255
  return vmath.vector4(r, g, b, a)
end

return M
