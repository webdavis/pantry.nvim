local rows = require("pantry.jumps.rows")

local M = {}

local markers = { "^<<<<<<<", "^|||||||", "^=======", "^>>>>>>>" }

local is_marker = function(line)
  for _, marker in ipairs(markers) do
    if line:find(marker) then
      return true
    end
  end
  return false
end

M.find = function(buf, cursor, direction, count)
  local found = {}
  for row, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    if is_marker(line) then
      table.insert(found, row)
    end
  end
  return rows.step(found, cursor[1], direction, count)
end

return M
