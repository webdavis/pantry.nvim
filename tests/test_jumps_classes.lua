local Helpers = require("tests.helpers")
local child, hooks = Helpers.jumps_child()
local j = Helpers.jumping(child)
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({ hooks = hooks })

local python = { "class A:", "    def f(self):", "        pass", "", "class B:", "    pass" }

local from = function(row, keys)
  j.open("python", python)
  j.at(row)
  child.type_keys(keys)
  return child.api.nvim_win_get_cursor(0)
end

T["]c goes to the next class start"] = function()
  eq(from(4, "]c"), { 5, 0 })
end

T["[c goes to the previous class start"] = function()
  eq(from(4, "[c"), { 2, 4 })
end

T["]C goes to the next class end"] = function()
  eq(from(4, "]C"), { 6, 7 })
end

T["[C goes to the previous class end"] = function()
  eq(from(4, "[C"), { 3, 11 })
end

T["in a diff window ]c and [c go to the next and previous change"] = function()
  j.open("text", { "a", "b", "c", "d", "e" })
  child.cmd("diffthis | vnew | diffthis")
  child.api.nvim_buf_set_lines(0, 0, -1, false, { "a", "X", "c", "d", "Y" })
  child.cmd("diffupdate")
  j.at(1)
  eq(j.press("]c"), 2)
  eq(j.press("]c"), 5)
  eq(j.press("[c"), 2)
end

T["without nvim-treesitter-textobjects the keys stay put"] = function()
  child.lua([[package.preload["nvim-treesitter-textobjects.move"] = function() error("not installed") end]])
  eq(from(4, "]c"), { 4, 0 })
end

return T
