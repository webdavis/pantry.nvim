local M = {}

local motion = { [1] = "}", [-1] = "{" }

M.move = function(direction, count)
  vim.cmd(("normal! %d%s"):format(count, motion[direction]))
end

return M
