----------------------------------------------------------------------------------------------------
-- CSV: Utils for parsing CSV files.
----------------------------------------------------------------------------------------------------

local M = {}

--- Parse CSV data.
--- @param str string CSV to parse.
--- @return table
--- @return function
function M.parse(str)
  local lines_iter = string.gmatch(str, "[^\r\n]+")

  local header = lines_iter()
  local _, num_columns = string.gsub(header, ",", "")

  local pattern = "^%s*(.-)"
  for _ = 1, num_columns do
    pattern = pattern .. ",%s*(.-)"
  end
  pattern = pattern .. "$"

  local header_columns = { string.match(header, pattern) }
  local function data_iter()
    local line = lines_iter()
    if line ~= nil then
      return string.match(line, pattern)
    end
  end

  return header_columns, data_iter
end

return M
