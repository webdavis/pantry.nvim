local scope = require("pantry.focus.scope")

local M = {}

local levels = {}
local lit = {}

local find = function(win)
  local buf = vim.api.nvim_win_get_buf(win)
  local chain, start = scope.chain(buf, vim.api.nvim_win_get_cursor(win)[1] - 1)
  levels[buf] = math.min(levels[buf] or start, #chain)
  return vim.tbl_extend("force", chain[levels[buf]], { buf = buf }), chain
end

M.reset = function()
  levels, lit = {}, {}
end

M.range = function(win, buf)
  if not lit[win] or lit[win].buf ~= buf then
    lit[win] = find(win)
  end
  return lit[win]
end

M.refresh = function(win)
  local range = find(win)
  local old = lit[win]
  lit[win] = range
  if not old or old.buf ~= range.buf or old.first ~= range.first or old.last ~= range.last then
    vim.api.nvim__redraw({ win = win, valid = false })
  end
end

M.step = function(win, delta)
  local buf = vim.api.nvim_win_get_buf(win)
  local _, chain = find(win)
  levels[buf] = math.max(1, math.min(levels[buf] + delta, #chain))
  M.refresh(win)
end

return M
