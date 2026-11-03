local M = {}

M.enabled = {}

M.setup = function(config)
  for name, opts in pairs(config or {}) do
    if opts.enabled ~= false then
      require("pantry." .. name).setup(opts)
      M.enabled[name] = true
    end
  end
end

return M
