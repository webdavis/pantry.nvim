local task = require("pantry.markdown.task")

return function()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line, shift = task.toggle(vim.api.nvim_get_current_line())
  vim.api.nvim_set_current_line(line)
  vim.api.nvim_win_set_cursor(0, { row, col + shift })
end
