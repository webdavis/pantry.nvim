local Helpers = require("tests.helpers")
local child, hooks = Helpers.new_child()
local screen = Helpers.screen(child)
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({ hooks = hooks })

local show = function(lines, setup)
  child.lua(setup or [[require("pantry.linelimit").setup()]])
  child.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end

T["colorcolumn +1 puts the limit at textwidth"] = function()
  child.bo.textwidth = 20
  child.wo.colorcolumn = "+1"
  show({ ("a"):rep(25) })
  eq(screen.line(1), ("a"):rep(25) .. " +5")
end

T["colorcolumn +3 puts the limit two columns past textwidth"] = function()
  child.bo.textwidth = 20
  child.wo.colorcolumn = "+3"
  show({ ("a"):rep(25) })
  eq(screen.line(1), ("a"):rep(25) .. " +3")
end

T["colorcolumn 100 puts the limit at 99"] = function()
  child.wo.colorcolumn = "100"
  show({ ("a"):rep(105) })
  eq(screen.line(2), ("a"):rep(25) .. " +6")
end

T["colorcolumn wins over textwidth and uses its first entry"] = function()
  child.bo.textwidth = 10
  child.wo.colorcolumn = "21,40"
  show({ ("a"):rep(25) })
  eq(screen.line(1), ("a"):rep(25) .. " +5")
end

T["textwidth wins over editorconfig"] = function()
  child.bo.textwidth = 20
  child.b.editorconfig = { max_line_length = "10" }
  show({ ("a"):rep(25) })
  eq(screen.line(1), ("a"):rep(25) .. " +5")
end

T["editorconfig max_line_length sets the limit"] = function()
  child.b.editorconfig = { max_line_length = "20" }
  show({ ("a"):rep(25) })
  eq(screen.line(1), ("a"):rep(25) .. " +5")
end

T["editorconfig wins over the filetypes option"] = function()
  child.bo.filetype = "lua"
  child.b.editorconfig = { max_line_length = "20" }
  show({ ("a"):rep(25) }, [[require("pantry.linelimit").setup({ filetypes = { lua = 10 } })]])
  eq(screen.line(1), ("a"):rep(25) .. " +5")
end

T["the filetypes option sets the limit for a filetype"] = function()
  child.bo.filetype = "lua"
  show({ ("a"):rep(25) }, [[require("pantry.linelimit").setup({ filetypes = { lua = 20 } })]])
  eq(screen.line(1), ("a"):rep(25) .. " +5")
end

T["a window with no limit shows nothing"] = function()
  child.b.editorconfig = { max_line_length = "off" }
  show({ ("a"):rep(15), ("a"):rep(25) })
  eq(screen.line(1), ("a"):rep(15))
  eq(screen.line(2), ("a"):rep(25))
end

return T
