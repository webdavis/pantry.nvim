local M = {}

local directions = { next = 1, prev = -1 }

local turned_off = function(opts)
  local off = {}
  for lhs, on in pairs(opts.keys or {}) do
    off[vim.keycode(lhs)] = on == false
  end
  return off
end

local jump = function(row)
  if vim.api.nvim_get_mode().mode == "n" then
    vim.cmd("normal! m'")
  end
  local first_nonblank = vim.fn.getline(row):find("%S") or 1
  vim.api.nvim_win_set_cursor(0, { row, first_nonblank - 1 })
end

local map = function(kind, way, buffer)
  vim.keymap.set(kind.modes, kind.keys[way], function()
    local buf = vim.api.nvim_get_current_buf()
    local row = kind.find(buf, vim.api.nvim_win_get_cursor(0), directions[way], vim.v.count1)
    if row then
      jump(row)
    end
  end, { buffer = buffer, desc = "jumps: " .. kind.desc[way] })
end

M.setup = function(opts)
  local off = turned_off(opts or {})
  for _, kind in ipairs(require("pantry.jumps.registry")) do
    for way in pairs(directions) do
      if not off[vim.keycode(kind.keys[way])] then
        map(kind, way)
      end
    end
  end
end

return M
