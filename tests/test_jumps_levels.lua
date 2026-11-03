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
  "  return x",
  "end",
}

T["{ goes out to the start of the enclosing block"] = function()
  j.open("lua", lua)
  j.at(4)
  eq(j.press("{"), 3)
  eq(j.press("{"), 1)
end

T["a count goes out several levels"] = function()
  j.open("lua", lua)
  j.at(4)
  eq(j.press("2{"), 1)
end

T["<C-o> returns to where { started"] = function()
  j.open("lua", lua)
  j.at(4)
  j.press("{")
  eq(j.press("<C-o>"), 4)
end

T["} retraces the levels { came out of"] = function()
  j.open("lua", lua)
  j.at(4)
  j.press("2{")
  eq(j.press("}"), 3)
  eq(j.press("}"), 4)
end

T["} without history goes to the first nested block"] = function()
  j.open("lua", lua)
  j.at(1)
  eq(j.press("}"), 3)
end

T["another cursor move forgets the history"] = function()
  j.open("lua", lua)
  j.at(4)
  j.press("{")
  j.press("k")
  eq(j.press("}"), 3)
end

T["{ follows Python blocks"] = function()
  j.open("python", { "def f(x):", "    if x:", "        return 1", "    return 2" })
  j.at(3)
  eq(j.press("{"), 2)
  eq(j.press("{"), 1)
end

T["{ follows JSON objects and keys"] = function()
  j.open("json", { "{", '  "a": 1,', '  "b": {', '    "c": 2', "  }", "}" })
  j.at(4)
  eq(j.press("{"), 3)
  eq(j.press("{"), 1)
end

T["{ follows YAML keys"] = function()
  j.open("yaml", { "a:", "  b:", "    c: 1", "d: 2" })
  j.at(3)
  eq(j.press("{"), 2)
  eq(j.press("{"), 1)
end

T["{ uses the built-in blocks when nvim-treesitter-context is missing"] = function()
  child.lua([[
    for _, dir in ipairs(vim.api.nvim_list_runtime_paths()) do
      if dir:find("nvim%-treesitter%-context") then
        vim.opt.runtimepath:remove(dir)
      end
    end
  ]])
  j.open("lua", lua)
  j.at(4)
  eq(j.press("{"), 3)
end

T["{ keeps the paragraph motion in a buffer without a parser"] = function()
  j.open("text", { "a", "", "b", "c" })
  j.at(4)
  eq(j.press("{"), 2)
end

T["visual { keeps the paragraph motion"] = function()
  j.open("lua", { "local a = 1", "", "local b = 2", "local c = 3" })
  j.at(4)
  eq(j.press("V{"), 2)
end

return T
