local Helpers = require("tests.helpers")
local child, hooks = Helpers.jumps_child()
local j = Helpers.jumping(child)
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({ hooks = hooks })

local lua = {
  "local function f(x)",
  "  local a = 1",
  "  if x then",
  "    print(a)",
  "  end",
  "  local t = {",
  "    one = 1,",
  "  }",
  "  return x",
  "end",
}

T["]j goes to the next statement at the same level"] = function()
  j.open("lua", lua)
  j.at(2)
  eq(j.press("]j"), 3)
  eq(j.press("]j"), 6)
  eq(j.press("]j"), 9)
end

T["]j stops at the end of the block"] = function()
  j.open("lua", lua)
  j.at(9)
  eq(j.press("]j"), 9)
end

T["[j goes to the previous statement at the same level"] = function()
  j.open("lua", lua)
  j.at(9)
  eq(j.press("[j"), 6)
  eq(j.press("[j"), 3)
end

T["a count skips statements"] = function()
  j.open("lua", lua)
  j.at(2)
  eq(j.press("2]j"), 6)
end

T["<C-o> returns to where ]j started"] = function()
  j.open("lua", lua)
  j.at(2)
  j.press("]j")
  eq(j.press("<C-o>"), 2)
end

T["]j walks Python statements"] = function()
  j.open("python", { "def f(x):", "    a = 1", "    if a:", "        b()", "    return a" })
  j.at(2)
  eq(j.press("]j"), 3)
  eq(j.press("]j"), 5)
end

local json = {
  "{",
  '  "a": 1,',
  '  "b": {',
  '    "c": 2',
  "  },",
  '  "d": [',
  "    1,",
  '    {"x": 2}',
  "  ]",
  "}",
}

T["]j moves between JSON keys at one level"] = function()
  j.open("json", json)
  j.at(2)
  eq(j.press("]j"), 3)
  eq(j.press("]j"), 6)
  eq(j.press("[j"), 3)
end

T["]j moves between JSON array elements"] = function()
  j.open("json", json)
  j.at(7)
  eq(j.press("]j"), 8)
end

local yaml = {
  "a:",
  "  b: 1",
  "  c:",
  "    d: 2",
  "list:",
  "  - one",
  "  - two: 2",
  "    three: 3",
  "e: 3",
}

T["]j moves between YAML keys at one level"] = function()
  j.open("yaml", yaml)
  j.at(1)
  eq(j.press("]j"), 5)
  eq(j.press("]j"), 9)
  j.at(2)
  eq(j.press("]j"), 3)
end

T["]j moves between YAML list items"] = function()
  j.open("yaml", yaml)
  j.at(6)
  eq(j.press("]j"), 7)
  j.at(8)
  eq(j.press("[j"), 7)
end

T["]j moves between TOML keys and tables"] = function()
  j.open("toml", { "[server]", 'host = "x"', "port = 1", "", "[db]", 'name = "y"' })
  j.at(2)
  eq(j.press("]j"), 3)
  j.at(1)
  eq(j.press("]j"), 5)
end

return T
