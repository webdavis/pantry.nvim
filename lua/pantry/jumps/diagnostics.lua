local M = {}

local mover = function(severity)
  return function(direction, count)
    vim.diagnostic.jump({ count = direction * count, severity = severity })
  end
end

M.errors = mover(vim.diagnostic.severity.ERROR)

M.warnings = mover(vim.diagnostic.severity.WARN)

return M
