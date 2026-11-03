local M = {}

M.is_visible = function()
  local blink = package.loaded["blink.cmp"]
  if blink then
    return blink.is_visible()
  end
  return vim.fn.pumvisible() == 1
end

return M
