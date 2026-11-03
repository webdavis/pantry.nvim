local M = {}

M.managed = function(win, opts)
  local buf = vim.api.nvim_win_get_buf(win)
  return vim.api.nvim_win_get_config(win).relative == ""
    and vim.bo[buf].buftype == ""
    and not vim.tbl_contains(opts.skip, vim.bo[buf].filetype)
end

return M
