local Helpers = require("tests.helpers")
local child, hooks = Helpers.new_child()
local e = Helpers.editing(child)
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({ hooks = hooks })

T["setup() with no options maps every key"] = function()
  child.lua([[require("pantry.rsi").setup()]])
  child.type_keys(":abc", "<C-b>")
  eq(e.cmdline(), { "abc", 3 })
end

T["a key set to false keeps Neovim's meaning in both modes"] = function()
  child.lua([[require("pantry.rsi").setup({ keys = { ["<C-k>"] = false } })]])
  e.lines({ "abc" })
  child.type_keys("0i", "<C-k>", "e:", "<Esc>")
  eq(e.line(), "ëabc")
  child.type_keys(":abc", "<C-a>", "<C-k>", "e:")
  eq(e.cmdline(), { "ëabc", 3 })
end

T["a key set to false leaves the other keys on"] = function()
  child.lua([[require("pantry.rsi").setup({ keys = { ["<C-k>"] = false } })]])
  child.type_keys(":abc", "<C-b>")
  eq(e.cmdline(), { "abc", 3 })
end

return T
