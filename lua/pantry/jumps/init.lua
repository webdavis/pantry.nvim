local M = {}

local directions = { next = 1, prev = -1 }

local map = function(kind, way, buffer)
  vim.keymap.set(kind.modes, kind.keys[way], function()
    local buf = vim.api.nvim_get_current_buf()
    local row = kind.find(buf, vim.api.nvim_win_get_cursor(0), directions[way], vim.v.count1)
    if row then
      require("pantry.cursor").jump_to_row(row)
    end
  end, { buffer = buffer, desc = "jumps: " .. kind.desc[way] })
end

local map_both_ways = function(kind, off, buffer)
  for way in pairs(directions) do
    if not off[vim.keycode(kind.keys[way])] then
      map(kind, way, buffer)
    end
  end
end

M.setup = function(opts)
  local off = require("pantry.keys").turned_off(opts or {})
  local group = vim.api.nvim_create_augroup("pantry.jumps", {})
  for _, kind in ipairs(require("pantry.jumps.registry")) do
    if kind.filetype then
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = kind.filetype,
        callback = function(event)
          map_both_ways(kind, off, event.buf)
        end,
      })
    else
      map_both_ways(kind, off)
    end
  end
end

return M
