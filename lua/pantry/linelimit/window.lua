local M = {}

M.managed = function(win, opts)
  local buf = vim.api.nvim_win_get_buf(win)
  return vim.api.nvim_win_get_config(win).relative == ""
    and vim.bo[buf].buftype == ""
    and not vim.tbl_contains(opts.skip, vim.bo[buf].filetype)
end

M.colorcolumn = function(win)
  return vim.w[win].pantry_colorcolumn or vim.wo[win].colorcolumn
end

M.hide_colorcolumn = function(win, opts)
  if vim.wo[win].colorcolumn == "" or not M.managed(win, opts) then
    return
  end
  vim.w[win].pantry_colorcolumn = vim.wo[win].colorcolumn
  vim.api.nvim_win_call(win, function()
    vim.cmd("noautocmd set colorcolumn=")
  end)
end

M.forget_colorcolumn = function(win)
  vim.w[win].pantry_colorcolumn = nil
end

M.copy_colorcolumn = function(from, to)
  vim.w[to].pantry_colorcolumn = vim.w[from].pantry_colorcolumn
end

M.restore_colorcolumn = function(win)
  local saved = vim.w[win].pantry_colorcolumn
  if saved then
    vim.wo[win].colorcolumn = saved
    M.forget_colorcolumn(win)
  end
end

return M
