local Helpers = require("tests.helpers")
local child, hooks = Helpers.jumps_child()
local j = Helpers.jumping(child)
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({ hooks = hooks })

local captured = function(capture)
  return child.lua_get(([[(function()
    local root = vim.treesitter.get_parser(0):parse()[1]:root()
    local query = vim.treesitter.query.get("swift", "textobjects")
    local found = {}
    for id, node in query:iter_captures(root, 0) do
      if query.captures[id] == %q then
        table.insert(found, vim.treesitter.get_node_text(node, 0))
      end
    end
    return found
  end)()]]):format(capture))
end

local swift = {
  "func run() {",
  "  let total = 3",
  '  var name: String = "x"',
  "}",
}

T["Swift variables are assignment text objects"] = function()
  j.open("swift", swift)
  eq(captured("assignment.outer"), { "let total = 3", 'var name: String = "x"' })
end

T["Swift assignments split into a name and a value"] = function()
  j.open("swift", swift)
  eq(captured("assignment.lhs"), { "total", "name" })
  eq(captured("assignment.rhs"), { "3", '"x"' })
  eq(captured("assignment.inner"), { "3", '"x"' })
end

return T
