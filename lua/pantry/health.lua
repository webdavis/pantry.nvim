local M = {}

M.check = function()
  vim.health.start("pantry")
  local names = vim.tbl_keys(require("pantry").enabled)
  table.sort(names)
  if #names == 0 then
    vim.health.info("No modules are on. Turn one on with require('pantry').setup({ rsi = {} }).")
  end
  for _, name in ipairs(names) do
    local jar = require("pantry." .. name)
    if jar.is_enabled and not jar.is_enabled() then
      vim.health.ok(name .. " is set up and off")
    else
      vim.health.ok(name .. " is on")
    end
  end
end

return M
