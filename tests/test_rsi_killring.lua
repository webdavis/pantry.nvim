local Helpers = require("tests.helpers")
local child, hooks = Helpers.rsi_child()
local e = Helpers.editing(child)
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({ hooks = hooks })

T["<C-y> pastes the latest kill"] = function()
  child.type_keys(":abc", "<C-u>", "x", "<C-y>")
  eq(e.cmdline(), { "xabc", 5 })
end

T["<C-y> with nothing killed leaves the line alone"] = function()
  child.type_keys(":abc", "<C-y>")
  eq(e.cmdline(), { "abc", 4 })
end

T["<M-y> right after <C-y> cycles through older kills"] = function()
  child.type_keys(":aaa", "<C-u>", "bbb", "<C-u>", "x", "<C-y>")
  eq(e.cmdline(), { "xbbb", 5 })
  child.type_keys("<M-y>")
  eq(e.cmdline(), { "xaaa", 5 })
  child.type_keys("<M-y>")
  eq(e.cmdline(), { "xbbb", 5 })
end

T["<M-y> does nothing when the last key was not a paste"] = function()
  child.type_keys(":aaa", "<C-u>", "bbb", "<C-u>", "<C-y>", "z", "<M-y>")
  eq(e.cmdline(), { "bbbz", 5 })
end

T["<M-d> and <C-k> on the command line push to the ring"] = function()
  child.type_keys(":foo bar baz", "<C-a>", "<M-d>", "<C-k>", "<C-y>")
  eq(e.cmdline(), { " bar baz", 9 })
  child.type_keys("<M-y>")
  eq(e.cmdline(), { "foo", 4 })
end

T["insert-mode kills reach the command-line ring"] = function()
  e.lines({ "foo bar baz" })
  child.type_keys("A", "<C-w>", "<C-a>", "<M-d>", "<C-k>", "<Esc>")
  eq(e.line(), "")
  child.type_keys(":", "<C-y>")
  eq(e.cmdline(), { " bar ", 6 })
  child.type_keys("<M-y>")
  eq(e.cmdline(), { "foo", 4 })
  child.type_keys("<M-y>")
  eq(e.cmdline(), { "baz", 4 })
end

T["insert-mode <C-u> pushes to the ring"] = function()
  e.lines({ "  foo bar" })
  child.type_keys("A", "<C-u>", "<Esc>", ":", "<C-y>")
  eq(e.cmdline(), { "foo bar", 8 })
end

return T
