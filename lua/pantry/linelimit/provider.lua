local measure = require("pantry.linelimit.measure")
local limit = require("pantry.linelimit.limit")
local window = require("pantry.linelimit.window")

local M = {}

local ns = vim.api.nvim_create_namespace("pantry.linelimit")
local views = {}

local draw = function(buf, row, found, view)
  if found.over then
    vim.api.nvim_buf_set_extmark(buf, ns, row, 0, {
      virt_text = { { "+" .. found.over, "PantryLineLimitOver" } },
      virt_text_pos = "eol",
      ephemeral = true,
    })
  elseif found.mark >= view.leftcol then
    vim.api.nvim_buf_set_extmark(buf, ns, row, 0, {
      virt_text = { { "│", "PantryLineLimit" } },
      virt_text_win_col = found.mark - view.leftcol,
      ephemeral = true,
    })
  end
end

M.attach = function(opts)
  vim.api.nvim_set_decoration_provider(ns, {
    on_win = function(_, win, buf)
      local max = window.managed(win, opts) and limit(win, buf, opts)
      views[win] = max and { limit = max, leftcol = vim.fn.getwininfo(win)[1].leftcol, tabstop = vim.bo[buf].tabstop }
        or nil
      return views[win] ~= nil
    end,
    on_line = function(_, win, buf, row)
      local view = views[win]
      local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1]
      local found = measure(line, view.limit, opts.near, view.tabstop)
      if found then
        draw(buf, row, found, view)
      end
    end,
  })
end

M.detach = function()
  vim.api.nvim_set_decoration_provider(ns, {})
end

return M
