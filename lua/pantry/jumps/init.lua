local M = {}

local directions = { next = 1, prev = -1 }

local map = function(kind, way)
  vim.keymap.set(kind.modes, kind.keys[way], function()
    if kind.move then
      return kind.move(directions[way], vim.v.count1)
    end
    local buf = vim.api.nvim_get_current_buf()
    local row = kind.find(buf, vim.api.nvim_win_get_cursor(0), directions[way], vim.v.count1)
    if row then
      require("pantry.cursor").jump_to_row(row)
    end
  end, { desc = "jumps: " .. kind.desc[way] })
end

local map_both_ways = function(kind, off)
  for way in pairs(directions) do
    local lhs = kind.keys[way]
    if lhs and not off[vim.keycode(lhs)] then
      map(kind, way)
    end
  end
end

M.setup = function(opts)
  local off = require("pantry.keys").turned_off(opts or {})
  for _, kind in ipairs(require("pantry.jumps.registry")) do
    map_both_ways(kind, off)
  end
end

return M
