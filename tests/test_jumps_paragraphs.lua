local Helpers = require("tests.helpers")
local child, hooks = Helpers.jumps_child()
local j = Helpers.jumping(child)
local e = Helpers.editing(child)
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({ hooks = hooks })

local paragraphs = { "a", "b", "", "c", "d", "", "e" }

T["]P goes to the blank line after the paragraph"] = function()
  j.open("lua", paragraphs)
  j.at(1)
  eq(j.press("]P"), 3)
  eq(j.press("]P"), 6)
end

T["[P goes to the blank line before the paragraph"] = function()
  j.open("lua", paragraphs)
  j.at(7)
  eq(j.press("[P"), 6)
  eq(j.press("[P"), 3)
end

T["a count moves over several paragraphs"] = function()
  j.open("lua", paragraphs)
  j.at(1)
  eq(j.press("2]P"), 6)
end

T["visual ]P extends the selection to the paragraph end"] = function()
  j.open("lua", paragraphs)
  j.at(1)
  j.press("V]Pd")
  eq(e.buffer(), { "c", "d", "", "e" })
end

T["d]P deletes to the paragraph end"] = function()
  j.open("lua", paragraphs)
  j.at(4)
  j.press("d]P")
  eq(e.buffer(), { "a", "b", "", "", "e" })
end

return T
