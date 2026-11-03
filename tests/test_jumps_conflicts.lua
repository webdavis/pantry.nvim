local Helpers = require("tests.helpers")
local child, hooks = Helpers.jumps_child()
local j = Helpers.jumping(child)
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({ hooks = hooks })

local conflict = {
  "a",
  "<<<<<<< HEAD",
  "ours",
  "=======",
  "theirs",
  ">>>>>>> branch",
  "b",
}

T["]n stops on each conflict marker in turn"] = function()
  j.open("text", conflict)
  j.at(1)
  eq(j.press("]n"), 2)
  eq(j.press("]n"), 4)
  eq(j.press("]n"), 6)
end

T["[n goes back to the previous marker"] = function()
  j.open("text", conflict)
  j.at(7)
  eq(j.press("[n"), 6)
  eq(j.press("[n"), 4)
end

T["a count skips markers"] = function()
  j.open("text", conflict)
  j.at(1)
  eq(j.press("3]n"), 6)
end

T["]n stays put past the last marker"] = function()
  j.open("text", conflict)
  j.at(6)
  eq(j.press("]n"), 6)
end

T["<C-o> returns to where ]n started"] = function()
  j.open("text", conflict)
  j.at(1)
  j.press("]n")
  eq(j.press("<C-o>"), 1)
end

T["markers that do not start the line are ignored"] = function()
  j.open("text", { "a", "  <<<<<<< HEAD", "b", ">>>>>>> branch" })
  j.at(1)
  eq(j.press("]n"), 4)
end

return T
