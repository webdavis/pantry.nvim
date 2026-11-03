local M = {}

M.check = function()
  vim.health.start("pantry")
  local names = vim.tbl_keys(require("pantry").enabled)
  table.sort(names)
  if #names == 0 then
    vim.health.info("No modules are on. Turn one on with require('pantry').setup({ rsi = {} }).")
  end
  for _, name in ipairs(names) do
    vim.health.ok(name .. " is on")
  end
end

return M
