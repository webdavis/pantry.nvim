local rows = require("pantry.jumps.rows")
local treesitter = require("pantry.jumps.treesitter")

local M = {}

local finder = function(source)
  local query_for = function(lang)
    return vim.treesitter.query.parse(lang, source)
  end
  return function(buf, cursor, direction, count)
    local found = treesitter.captures(buf, query_for, "jump")
    return rows.step(treesitter.start_rows(found), cursor[1], direction, count)
  end
end

M.fences = finder("(fenced_code_block) @jump")

M.checkboxes = finder("[(task_list_marker_checked) (task_list_marker_unchecked)] @jump")

return M
