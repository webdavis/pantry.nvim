local provider = require("pantry.linelimit.provider")
local window = require("pantry.linelimit.window")

local M = {}

local config = { near = 10, filetypes = {}, skip = { "help", "qf", "man", "terminal", "prompt" } }

local define_highlights = function()
  vim.api.nvim_set_hl(0, "PantryLineLimit", { link = "NonText", default = true })
  vim.api.nvim_set_hl(0, "PantryLineLimitOver", { link = "DiagnosticVirtualTextWarn", default = true })
end

local group = "pantry.linelimit"

local watch_colorcolumn = function()
  local id = vim.api.nvim_create_augroup(group, {})
  vim.api.nvim_create_autocmd({ "BufWinEnter", "VimEnter" }, {
    group = id,
    callback = function()
      window.hide_colorcolumn(vim.api.nvim_get_current_win(), config)
    end,
  })
  vim.api.nvim_create_autocmd("OptionSet", {
    group = id,
    pattern = "colorcolumn",
    callback = function()
      local win = vim.api.nvim_get_current_win()
      if vim.v.option_new == "" then
        window.forget_colorcolumn(win)
      else
        window.hide_colorcolumn(win, config)
      end
    end,
  })
  vim.api.nvim_create_autocmd("WinNew", {
    group = id,
    callback = function()
      window.copy_colorcolumn(vim.fn.win_getid(vim.fn.winnr("#")), vim.api.nvim_get_current_win())
    end,
  })
end

M.enable = function()
  provider.attach(config)
  watch_colorcolumn()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    window.hide_colorcolumn(win, config)
  end
end

M.disable = function()
  provider.detach()
  vim.api.nvim_create_augroup(group, {})
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    window.restore_colorcolumn(win)
  end
end

M.setup = function(opts)
  config = vim.tbl_extend("force", config, opts or {})
  define_highlights()
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("pantry.linelimit.highlights", {}),
    callback = define_highlights,
  })
  if config.enabled ~= false then
    M.enable()
  end
end

return M
