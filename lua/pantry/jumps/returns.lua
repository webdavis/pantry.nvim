local rows = require("pantry.jumps.rows")
local treesitter = require("pantry.jumps.treesitter")

local M = {}

local textobjects = function(lang)
  return vim.treesitter.query.get(lang, "textobjects")
end

M.find = function(buf, cursor, direction, count)
  local returns = treesitter.captures(buf, textobjects, "return.outer")
  return rows.step(treesitter.start_rows(returns), cursor[1], direction, count)
end

return M
