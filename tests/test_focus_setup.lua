local Helpers = require("tests.helpers")
local child, hooks = Helpers.new_child()
local f = Helpers.focusing(child)
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({ hooks = hooks })

local lua = { "local function f(x)", "  if x then", "    print(x)", "  end", "end" }

local mapped = function(lhs)
  return child.lua_get(('vim.fn.maparg(%q, "n", false, true).buffer == 1'):format(lhs))
end

T["the keys exist only while focus is on"] = function()
  child.lua([[require("pantry.focus").setup()]])
  eq({ mapped("<M-o>"), mapped("<M-i>") }, { false, false })
  f.call("enable")
  eq({ mapped("<M-o>"), mapped("<M-i>") }, { true, true })
  f.call("disable")
  eq({ mapped("<M-o>"), mapped("<M-i>") }, { false, false })
end

T["<M-o> shows more and <M-i> shows less"] = function()
  child.lua([[require("pantry.focus").setup()]])
  f.open("lua", lua)
  f.at(3)
  f.call("enable")
  child.type_keys("<M-o>")
  eq(f.lit(), { 1, 2, 3, 4, 5 })
  child.type_keys("<M-i>", "<M-i>")
  eq(f.lit(), { 3 })
end

T["the keys follow focus into another buffer"] = function()
  child.lua([[require("pantry.focus").setup()]])
  f.call("enable")
  child.api.nvim_set_current_buf(child.api.nvim_create_buf(true, false))
  eq(mapped("<M-o>"), true)
  f.call("disable")
  eq(mapped("<M-o>"), false)
end

T["the keys come back when Neovim reuses an empty buffer"] = function()
  child.lua([[require("pantry.focus").setup()]])
  f.call("enable")
  child.cmd("enew")
  eq(mapped("<M-o>"), true)
end

T["a key set to false stays unmapped"] = function()
  child.lua([[require("pantry.focus").setup({ keys = { ["<M-o>"] = false } })]])
  f.call("enable")
  eq({ mapped("<M-o>"), mapped("<M-i>") }, { false, true })
end

T["enabled = true turns focus on at setup"] = function()
  f.open("lua", lua)
  f.at(3)
  child.lua([[require("pantry").setup({ focus = { enabled = true } })]])
  eq(f.lit(), { 2, 3, 4 })
end

return T
