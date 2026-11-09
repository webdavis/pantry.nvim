local M = {}

M.jump_to_row = function(row)
  if vim.api.nvim_get_mode().mode == "n" then
    vim.cmd("normal! m'")
  end
  local first_nonblank = vim.fn.getline(row):find("%S") or 1
  vim.api.nvim_win_set_cursor(0, { row, first_nonblank - 1 })
end

return M
