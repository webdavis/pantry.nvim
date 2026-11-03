local child, hooks = require("tests.helpers").new_child()
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({ hooks = hooks })

local is_loaded = function(name)
  return child.lua_get(("package.loaded[%q] ~= nil"):format(name))
end

T["setup() turns on a named module"] = function()
  child.lua([[require("pantry").setup({ rsi = {} })]])
  child.type_keys(":abc", "<C-b>")
  eq(child.fn.getcmdpos(), 3)
end

T["setup() passes module options through"] = function()
  child.lua([[require("pantry").setup({ rsi = { keys = { ["<C-b>"] = false } } })]])
  child.type_keys(":abc", "<C-b>")
  eq(child.fn.getcmdpos(), 1)
end

T["setup() leaves a module off when enabled is false"] = function()
  child.lua([[require("pantry").setup({ rsi = { enabled = false } })]])
  eq(is_loaded("pantry.rsi"), false)
end

T["setup() never loads a module that is not named"] = function()
  child.lua([[require("pantry").setup({})]])
  eq(is_loaded("pantry.rsi"), false)
end

T["setup() loads any module name that resolves"] = function()
  child.lua([[
    package.preload["pantry.fake"] = function()
      return { setup = function(opts) _G.fake_opts = opts end }
    end
    require("pantry").setup({ fake = { answer = 42 } })
  ]])
  eq(child.lua_get("_G.fake_opts.answer"), 42)
end

T["checkhealth pantry lists the modules that are on"] = function()
  child.lua([[require("pantry").setup({ rsi = {}, linelimit = { enabled = false } })]])
  child.cmd("checkhealth pantry")
  local report = table.concat(child.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  eq(report:find("rsi is on", 1, true) ~= nil, true)
  eq(report:find("linelimit", 1, true) ~= nil, false)
end

T["checkhealth pantry says when no jar is on"] = function()
  child.cmd("checkhealth pantry")
  local report = table.concat(child.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  eq(report:find("No jars are on", 1, true) ~= nil, true)
end

return T
