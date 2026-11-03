local Helpers = require("tests.helpers")
local child, hooks = Helpers.new_child()
local screen = Helpers.screen(child)
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({ hooks = hooks })

local long = ("a"):rep(25)

local setup = function()
  child.api.nvim_buf_set_lines(0, 0, -1, false, { long })
  child.lua([[require("pantry.linelimit").setup()]])
end

T["the colorcolumn stripe is hidden and its limit still used"] = function()
  child.bo.textwidth = 20
  child.wo.colorcolumn = "+3"
  setup()
  eq(child.wo.colorcolumn, "")
  eq(screen.line(1), long .. " +3")
end

T["disable() puts the colorcolumn back"] = function()
  child.bo.textwidth = 20
  child.wo.colorcolumn = "+3"
  setup()
  child.lua([[require("pantry.linelimit").disable()]])
  eq(child.wo.colorcolumn, "+3")
  eq(screen.line(1), long)
end

T["a colorcolumn set later is hidden and used"] = function()
  setup()
  child.cmd("setlocal colorcolumn=21")
  eq(child.wo.colorcolumn, "")
  eq(screen.line(1), long .. " +5")
end

T["a split keeps the limit from colorcolumn"] = function()
  child.wo.colorcolumn = "21"
  setup()
  child.cmd("split")
  eq(child.wo.colorcolumn, "")
  eq(screen.line(1), long .. " +5")
  child.lua([[require("pantry.linelimit").disable()]])
  eq(child.wo.colorcolumn, "21")
end

T["clearing colorcolumn removes its limit"] = function()
  child.wo.colorcolumn = "21"
  setup()
  child.cmd("setlocal colorcolumn=")
  eq(screen.line(1), long)
end

T["a skipped window keeps its colorcolumn"] = function()
  child.bo.buftype = "nofile"
  child.wo.colorcolumn = "21"
  setup()
  eq(child.wo.colorcolumn, "21")
end

T["a colorcolumn set during startup after setup is hidden"] = function()
  child.restart({
    "-u",
    "scripts/minimal_init.lua",
    "-c",
    [[lua require("pantry.linelimit").setup(); vim.o.colorcolumn = "21"]],
  })
  eq(child.wo.colorcolumn, "")
end

return T
