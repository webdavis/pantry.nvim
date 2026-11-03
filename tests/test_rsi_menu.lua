local Helpers = require("tests.helpers")
local child, hooks = Helpers.rsi_child()
local e = Helpers.editing(child)
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({ hooks = hooks })

T["insert <C-e> goes to blink while its menu is open"] = function()
  e.open_menu()
  e.lines({ "abc", "xyz" })
  child.type_keys("ggi", "<C-e>")
  eq(e.line(), "xabc")
end

T["insert <C-k> goes to blink while its menu is open"] = function()
  e.open_menu()
  e.lines({ "abc" })
  child.type_keys("0i", "<C-k>", "e:")
  eq(e.line(), "ëabc")
end

T["command-line <C-k> goes to blink while its menu is open"] = function()
  e.open_menu()
  child.type_keys(":abc", "<C-a>", "<C-k>", "e:")
  eq(e.cmdline(), { "ëabc", 3 })
end

T["command-line <C-y> goes to blink while its menu is open"] = function()
  child.type_keys(":abc", "<C-u>")
  e.open_menu()
  child.type_keys("<C-y>")
  eq(e.cmdline(), { "\25", 2 })
end

T["insert <C-e> goes to the built-in popup menu without blink"] = function()
  e.lines({ "foobar", "foobaz", "x" })
  child.type_keys("G0i", "foo", "<C-n>", "<C-e>")
  eq(e.line(), "foox")
end

return T
