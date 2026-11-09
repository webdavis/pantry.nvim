local task = require("pantry.markdown.task")
local eq = MiniTest.expect.equality

local T = MiniTest.new_set()

local cases = {
  { "a plain line becomes a task", "write tests", "- [ ] write tests", 6 },
  { "a plain line keeps its indent", "  write tests", "  - [ ] write tests", 6 },
  { "an empty line becomes an empty task", "", "- [ ] ", 6 },
  { "a dash item gains a box", "- item", "- [ ] item", 4 },
  { "a star item gains a box", "* item", "* [ ] item", 4 },
  { "a plus item gains a box", "+ item", "+ [ ] item", 4 },
  { "a numbered item with a dot gains a box", "1. item", "1. [ ] item", 4 },
  { "a numbered item with a paren gains a box", "12) item", "12) [ ] item", 4 },
  { "a nested item keeps its indent", "    - item", "    - [ ] item", 4 },
  { "an open task is checked", "- [ ] todo", "- [x] todo", 0 },
  { "a checked task is opened", "- [x] done", "- [ ] done", 0 },
  { "a task checked with a capital X is opened", "* [X] done", "* [ ] done", 0 },
  { "a numbered task is checked", "3. [ ] todo", "3. [x] todo", 0 },
  { "a dash with no space is plain text", "-item", "- [ ] -item", 6 },
}

for _, case in ipairs(cases) do
  T[case[1]] = function()
    eq({ task.toggle(case[2]) }, { case[3], case[4] })
  end
end

return T
