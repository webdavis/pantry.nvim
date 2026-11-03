local Helpers = require("tests.helpers")
local child, hooks = Helpers.new_child([[require("pantry.focus").setup()]])
local f = Helpers.focusing(child)
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({ hooks = hooks })

local lua = {
  "local function f(x)",
  "  local a = 1",
  "  if x then",
  "    print(a)",
  "  end",
  "  return x",
  "end",
  "local b = 2",
}

local json = {
  "{",
  '  "a": 1,',
  '  "b": {',
  '    "c": 2,',
  '    "d": 3',
  "  }",
  "}",
}

T["setup leaves every line lit until focus is enabled"] = function()
  f.open("lua", lua)
  f.at(4)
  eq(f.lit(), { 1, 2, 3, 4, 5, 6, 7, 8 })
end

T["enable lights the enclosing block and dims the rest"] = function()
  f.open("lua", lua)
  f.at(4)
  f.call("enable")
  eq(f.lit(), { 3, 4, 5 })
end

T["widen lights the next block out and narrow goes back"] = function()
  f.open("lua", lua)
  f.at(4)
  f.call("enable")
  f.call("widen")
  eq(f.lit(), { 2, 3, 4, 5, 6 })
  f.call("narrow")
  eq(f.lit(), { 3, 4, 5 })
end

T["widen ends at the whole buffer"] = function()
  f.open("lua", lua)
  f.at(4)
  f.call("enable")
  for _ = 1, 5 do
    f.call("widen")
  end
  eq(f.lit(), { 1, 2, 3, 4, 5, 6, 7, 8 })
  f.call("narrow")
  eq(f.lit(), { 1, 2, 3, 4, 5, 6, 7 })
end

T["narrow lights one key and value line in JSON"] = function()
  f.open("json", json)
  f.at(4)
  f.call("enable")
  eq(f.lit(), { 3, 4, 5, 6 })
  f.call("narrow")
  eq(f.lit(), { 4 })
end

T["narrow stops at the line under the cursor"] = function()
  f.open("json", json)
  f.at(4)
  f.call("enable")
  f.call("narrow")
  f.call("narrow")
  eq(f.lit(), { 4 })
end

T["the lit range follows the cursor at the same level"] = function()
  f.open("json", json)
  f.at(4)
  f.call("enable")
  f.call("narrow")
  child.type_keys("j")
  eq(f.lit(), { 5 })
end

T["a buffer without a parser lights the paragraph and then everything"] = function()
  f.open("text", { "a", "b", "", "c", "d" })
  f.at(4)
  f.call("enable")
  eq(f.lit(), { 3, 4, 5 })
  f.call("widen")
  eq(f.lit(), { 1, 2, 3, 4, 5 })
end

T["disable lights every line again"] = function()
  f.open("lua", lua)
  f.at(4)
  f.call("enable")
  f.call("disable")
  eq(f.lit(), { 1, 2, 3, 4, 5, 6, 7, 8 })
end

T["toggle turns focus on and off"] = function()
  f.open("lua", lua)
  f.at(4)
  f.call("toggle")
  eq(f.lit(), { 3, 4, 5 })
  f.call("toggle")
  eq(f.lit(), { 1, 2, 3, 4, 5, 6, 7, 8 })
end

T["dimmed lines use PantryFocusDim, which links to Comment"] = function()
  eq(child.api.nvim_get_hl(0, { name = "PantryFocusDim" }).link, "Comment")
end

return T
