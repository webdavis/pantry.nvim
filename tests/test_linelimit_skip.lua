local Helpers = require("tests.helpers")
local child, hooks = Helpers.new_child()
local screen = Helpers.screen(child)
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({ hooks = hooks })

local long = ("a"):rep(25)

local show = function(setup, buffer_options)
  child.lua(buffer_options or "")
  child.lua(setup or [[require("pantry.linelimit").setup()]])
  child.bo.textwidth = 20
  child.api.nvim_buf_set_lines(0, 0, -1, false, { long })
end

T["a floating window is skipped"] = function()
  show()
  child.lua(([[
    local buf = vim.api.nvim_create_buf(true, false)
    vim.bo[buf].textwidth = 20
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { %q })
    vim.api.nvim_open_win(buf, false, { relative = "editor", row = 4, col = 0, width = 40, height = 1 })
  ]]):format(long))
  eq(screen.line(1), long .. " +5")
  eq(screen.line(5), long)
end

T["a buffer with a buftype is skipped"] = function()
  show(nil, [[vim.bo.buftype = "nofile"]])
  eq(screen.line(1), long)
end

T["a filetype in skip is skipped"] = function()
  show([[require("pantry.linelimit").setup({ skip = { "markdown" } })]], [[vim.bo.filetype = "markdown"]])
  eq(screen.line(1), long)
end

return T
