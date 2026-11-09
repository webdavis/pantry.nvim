local M = {}

local map = function(buf, off)
  for _, key in ipairs(require("pantry.markdown.registry")) do
    if not off[vim.keycode(key.lhs)] then
      vim.keymap.set(key.modes, key.lhs, key.action, { buffer = buf, desc = "markdown: " .. key.desc })
    end
  end
end

M.setup = function(opts)
  local off = require("pantry.keys").turned_off(opts or {})
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("pantry.markdown", {}),
    pattern = "markdown",
    callback = function(event)
      map(event.buf, off)
    end,
  })
end

return M
