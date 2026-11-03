local provider = require("pantry.linelimit.provider")

local M = {}

local config = { near = 10, filetypes = {}, skip = { "help", "qf", "man", "terminal", "prompt" } }

local define_highlights = function()
  vim.api.nvim_set_hl(0, "PantryLineLimit", { link = "NonText", default = true })
  vim.api.nvim_set_hl(0, "PantryLineLimitOver", { link = "DiagnosticVirtualTextWarn", default = true })
end

M.enable = function()
  provider.attach(config)
end

M.disable = function()
  provider.detach()
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
