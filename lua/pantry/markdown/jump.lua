local M = {}

M.to = function(find, direction)
  return function()
    local row = find(vim.api.nvim_get_current_buf(), vim.api.nvim_win_get_cursor(0), direction, vim.v.count1)
    if row then
      require("pantry.cursor").jump_to_row(row)
    end
  end
end

return M
