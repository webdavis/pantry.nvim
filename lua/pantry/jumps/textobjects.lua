local M = {}

local way = { [1] = "goto_next", [-1] = "goto_previous" }

M.mover = function(edge, captures, group)
  return function(direction)
    local ok, move = pcall(require, "nvim-treesitter-textobjects.move")
    if ok then
      move[way[direction] .. edge](captures, group or "textobjects")
    end
  end
end

local class_starts = M.mover("_start", { "@class.outer", "@class.inner" })

local change = { [1] = "]c", [-1] = "[c" }

M.class_starts_or_changes = function(direction, count)
  if vim.wo.diff then
    return vim.cmd(("normal! %d%s"):format(count, change[direction]))
  end
  class_starts(direction)
end

return M
