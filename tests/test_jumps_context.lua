local Helpers = require("tests.helpers")
local child, hooks = Helpers.jumps_child()
local j = Helpers.jumping(child)
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({ hooks = hooks })

local nested = function()
  local lines = { "local function outer()", "  for i = 1, 3 do" }
  for row = 3, 60 do
    lines[row] = "    print(i)"
  end
  vim.list_extend(lines, { "  end", "end" })
  j.open("lua", lines)
  j.at(45)
  child.cmd("normal! zt")
  j.at(50)
end

T["[[ goes up to the context header"] = function()
  nested()
  eq(j.press("[["), 2)
end

T["a count goes up more headers"] = function()
  nested()
  eq(j.press("2[["), 1)
end

T["<C-o> returns to where [[ started"] = function()
  nested()
  j.press("[[")
  eq(j.press("<C-o>"), 50)
end

T["without nvim-treesitter-context [[ stays put"] = function()
  child.lua([[
    package.loaded["treesitter-context"] = nil
    package.preload["treesitter-context"] = function()
      error("not installed")
    end
  ]])
  nested()
  eq(j.press("[["), 50)
end

T["a buffer-local [[ from another plugin still wins"] = function()
  nested()
  child.lua([[vim.keymap.set("n", "[[", "<Cmd>let g:other = 1<CR>", { buffer = true })]])
  eq(j.press("[["), 50)
  eq(child.g.other, 1)
end

T["]] keeps Neovim's meaning"] = function()
  eq(child.fn.maparg("]]", "n"), "")
end

return T
