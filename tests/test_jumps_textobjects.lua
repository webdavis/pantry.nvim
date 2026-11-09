local Helpers = require("tests.helpers")
local child, hooks = Helpers.jumps_child()
local j = Helpers.jumping(child)
local e = Helpers.editing(child)
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({ hooks = hooks })

local lua = {
  "local function f(a, b)",
  "  -- note",
  "  for i = 1, a do",
  "    if i > b then",
  "      local x = i",
  "    end",
  "  end",
  "end",
  "",
  "local function g(c)",
  "  return c",
  "end",
}

local from = function(row, keys)
  j.open("lua", lua)
  j.at(row)
  child.type_keys(keys)
  return child.api.nvim_win_get_cursor(0)
end

local moves = {
  { "]m", 9, { 10, 0 } },
  { "[m", 9, { 3, 2 } },
  { "]M", 9, { 11, 9 } },
  { "[M", 9, { 8, 2 } },
  { "]l", 1, { 3, 2 } },
  { "[l", 9, { 4, 4 } },
  { "]L", 1, { 6, 6 } },
  { "[L", 9, { 7, 4 } },
  { "]s", 1, { 3, 2 } },
  { "[s", 9, { 8, 2 } },
  { "]z", 9, { 10, 0 } },
  { "[z", 9, { 8, 2 } },
  { "]k", 1, { 4, 4 } },
  { "[k", 9, { 6, 6 } },
  { "]v", 1, { 5, 12 } },
  { "[v", 9, { 5, 12 } },
  { "],", 1, { 1, 17 } },
  { "[,", 9, { 1, 20 } },
  { "]3", 1, { 2, 2 } },
  { "[3", 9, { 2, 2 } },
}

for _, move in ipairs(moves) do
  local keys, row, target = unpack(move)
  T[("%s from line %d goes to %d:%d"):format(keys, row, target[1], target[2])] = function()
    eq(from(row, keys), target)
  end
end

T["a count repeats the move"] = function()
  eq(from(1, "2]m"), { 10, 0 })
end

T["visual ]m extends the selection to the next function"] = function()
  from(9, "v]md")
  eq(e.buffer()[9], "ocal function g(c)")
end

T["d]3 deletes through the first character of the next comment"] = function()
  from(1, "d]3")
  eq(e.buffer()[1], "- note")
end

return T
