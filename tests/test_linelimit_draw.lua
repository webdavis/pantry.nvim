local Helpers = require("tests.helpers")
local child, hooks = Helpers.new_child()
local screen = Helpers.screen(child)
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({ hooks = hooks })

local show = function(lines, setup)
  child.lua(setup or [[require("pantry.linelimit").setup()]])
  child.bo.textwidth = 20
  child.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end

T["the mark appears only on lines near the limit"] = function()
  show({ "short", ("a"):rep(15) })
  eq(screen.cell(1, 21), " ")
  eq(screen.cell(2, 21), "│")
end

T["a line over the limit shows how many columns it is over"] = function()
  show({ ("a"):rep(25) })
  eq(screen.line(1), ("a"):rep(25) .. " +5")
end

T["a line over the limit gets no mark"] = function()
  show({ ("a"):rep(25) })
  eq(screen.cell(1, 21), "a")
end

T["a tab-indented line is measured in screen columns"] = function()
  show({ "\t\taaa", "\t\t\taaa" })
  eq(screen.cell(1, 21), "│")
  eq(screen.line(2):sub(-3), " +7")
end

T["the mark follows a horizontal scroll"] = function()
  show({ ("a"):rep(15) .. "b", ("a"):rep(80) })
  child.wo.wrap = false
  child.cmd("normal! 5zl")
  eq(screen.cell(1, 16), "│")
end

T["pantry.setup turns the module on"] = function()
  show({ ("a"):rep(15) }, [[require("pantry").setup({ linelimit = {} })]])
  eq(screen.cell(1, 21), "│")
end

T["near sets how close a line must be to get the mark"] = function()
  show({ ("a"):rep(15) }, [[require("pantry.linelimit").setup({ near = 3 })]])
  eq(screen.cell(1, 21), " ")
end

T["disable() stops drawing and enable() starts again"] = function()
  show({ ("a"):rep(15) })
  child.lua([[require("pantry.linelimit").disable()]])
  eq(screen.cell(1, 21), " ")
  child.lua([[require("pantry.linelimit").enable()]])
  eq(screen.cell(1, 21), "│")
end

T["enabled = false leaves drawing off"] = function()
  show({ ("a"):rep(15) }, [[require("pantry.linelimit").setup({ enabled = false })]])
  eq(screen.cell(1, 21), " ")
end

T["a colorscheme can set its own highlights"] = function()
  child.lua([[vim.api.nvim_set_hl(0, "PantryLineLimit", { fg = "#ff0000" })]])
  show({ ("a"):rep(15) })
  eq(child.api.nvim_get_hl(0, { name = "PantryLineLimit" }).fg, 0xff0000)
  eq(child.api.nvim_get_hl(0, { name = "PantryLineLimitOver" }).link ~= nil, true)
end

return T
