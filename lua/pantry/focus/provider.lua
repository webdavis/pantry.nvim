local view = require("pantry.focus.view")

local M = {}

local ns = vim.api.nvim_create_namespace("pantry.focus")

local managed = function(win, buf)
  return vim.api.nvim_win_get_config(win).relative == "" and vim.bo[buf].buftype == ""
end

local dim = function(buf, row)
  vim.api.nvim_buf_set_extmark(buf, ns, row, 0, {
    end_row = row + 1,
    end_col = 0,
    hl_group = "PantryFocusDim",
    ephemeral = true,
  })
end

M.attach = function()
  vim.api.nvim_set_decoration_provider(ns, {
    on_win = function(_, win, buf, top, bottom)
      if not managed(win, buf) then
        return false
      end
      local range = view.range(win, buf)
      for row = top, bottom do
        if row < range.first or row > range.last then
          dim(buf, row)
        end
      end
      return false
    end,
  })
end

M.detach = function()
  vim.api.nvim_set_decoration_provider(ns, {})
end

return M
