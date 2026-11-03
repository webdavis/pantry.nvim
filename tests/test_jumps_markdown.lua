local Helpers = require("tests.helpers")
local child, hooks = Helpers.jumps_child()
local j = Helpers.jumping(child)
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({ hooks = hooks })

local markdown = {
  "# Title",
  "",
  "- [ ] todo",
  "- [x] done",
  "",
  "```lua",
  "print(1)",
  "```",
  "",
  "```sh",
  "- [ ] not a task",
  "```",
  "",
  "* [X] last",
}

T["]` goes to the next fenced code block"] = function()
  j.open("markdown", markdown)
  j.at(1)
  eq(j.press("]`"), 6)
  eq(j.press("]`"), 10)
end

T["[` goes to the previous fenced code block"] = function()
  j.open("markdown", markdown)
  j.at(14)
  eq(j.press("[`"), 10)
  eq(j.press("[`"), 6)
end

T["]x goes to the next checkbox and skips code blocks"] = function()
  j.open("markdown", markdown)
  j.at(1)
  eq(j.press("]x"), 3)
  eq(j.press("]x"), 4)
  eq(j.press("]x"), 14)
end

T["[x goes to the previous checkbox"] = function()
  j.open("markdown", markdown)
  j.at(14)
  eq(j.press("[x"), 4)
end

T["<C-o> returns to where ]x started"] = function()
  j.open("markdown", markdown)
  j.at(1)
  j.press("2]x")
  eq(j.press("<C-o>"), 1)
end

T["markdown keys only exist in markdown buffers"] = function()
  j.open("lua", { "-- - [ ] note", "local a = 1", "-- - [ ] note" })
  j.at(1)
  eq(j.press("]x"), 1)
end

return T
