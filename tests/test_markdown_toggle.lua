local Helpers = require("tests.helpers")
local child, hooks = Helpers.markdown_child()
local j = Helpers.jumping(child)
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({ hooks = hooks })

local cursor = function()
  return child.api.nvim_win_get_cursor(0)
end

local line = function()
  return child.api.nvim_get_current_line()
end

T["<C-CR> makes a plain line a task and keeps the cursor on its character"] = function()
  j.open("markdown", { "write tests" })
  child.api.nvim_win_set_cursor(0, { 1, 6 })
  child.type_keys("<C-CR>")
  eq(line(), "- [ ] write tests")
  eq(cursor(), { 1, 12 })
end

T["<C-CR> checks and opens a task"] = function()
  j.open("markdown", { "- [ ] todo" })
  child.type_keys("<C-CR>")
  eq(line(), "- [x] todo")
  child.type_keys("<C-CR>")
  eq(line(), "- [ ] todo")
end

T["<C-CR> in insert mode keeps typing where the cursor was"] = function()
  j.open("markdown", { "- item" })
  child.type_keys("A", "<C-CR>", "!")
  eq(line(), "- [ ] item!")
  eq(child.fn.mode(), "i")
end

T["<C-CR> in insert mode mid-line keeps the cursor on its character"] = function()
  j.open("markdown", { "write tests" })
  child.api.nvim_win_set_cursor(0, { 1, 5 })
  child.type_keys("i", "<C-CR>", "!")
  eq(line(), "- [ ] write! tests")
end

T["<C-CR> only toggles in markdown buffers"] = function()
  j.open("lua", { "write tests" })
  child.type_keys("<C-CR>")
  eq(line(), "write tests")
end

T["<C-CR> set to false stays unmapped"] = function()
  child.lua([[require("pantry.markdown").setup({ keys = { ["<C-CR>"] = false } })]])
  j.open("markdown", { "write tests" })
  child.type_keys("<C-CR>")
  eq(line(), "write tests")
end

return T
