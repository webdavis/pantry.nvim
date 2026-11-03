local provider = require("pantry.focus.provider")
local view = require("pantry.focus.view")

local M = {}

local config = { enabled = false }
local on = false
local group = "pantry.focus"

local define_highlights = function()
  vim.api.nvim_set_hl(0, "PantryFocusDim", { link = "Comment", default = true })
end

local follow = function()
  local id = vim.api.nvim_create_augroup(group, {})
  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "TextChanged", "TextChangedI", "BufWinEnter" }, {
    group = id,
    callback = function()
      view.refresh(vim.api.nvim_get_current_win())
    end,
  })
end

M.enable = function()
  if on then
    return
  end
  on = true
  view.reset()
  provider.attach()
  follow()
  vim.api.nvim__redraw({ valid = false })
end

M.disable = function()
  if not on then
    return
  end
  on = false
  provider.detach()
  vim.api.nvim_create_augroup(group, {})
  vim.api.nvim__redraw({ valid = false })
end

M.toggle = function()
  if on then
    M.disable()
  else
    M.enable()
  end
end

M.widen = function()
  if on then
    view.step(vim.api.nvim_get_current_win(), 1)
  end
end

M.narrow = function()
  if on then
    view.step(vim.api.nvim_get_current_win(), -1)
  end
end

M.setup = function(opts)
  config = vim.tbl_extend("force", config, opts or {})
  define_highlights()
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("pantry.focus.highlights", {}),
    callback = define_highlights,
  })
  if config.enabled then
    M.enable()
  end
end

return M
