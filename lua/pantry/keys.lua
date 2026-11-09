local M = {}

M.turned_off = function(opts)
  local off = {}
  for lhs, on in pairs(opts.keys or {}) do
    off[vim.keycode(lhs)] = on == false
  end
  return off
end

return M
