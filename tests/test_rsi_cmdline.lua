local Helpers = require("tests.helpers")
local child, hooks = Helpers.rsi_child()
local e = Helpers.editing(child)
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({ hooks = hooks })

T["<C-a> moves to the start"] = function()
  child.type_keys(":abc", "<C-a>")
  eq(e.cmdline(), { "abc", 1 })
end

T["<C-b> and <C-f> move one character"] = function()
  child.type_keys(":abc", "<C-b>", "<C-b>")
  eq(e.cmdline(), { "abc", 2 })
  child.type_keys("<C-f>")
  eq(e.cmdline(), { "abc", 3 })
end

T["<C-f> at the end opens the command-line window"] = function()
  child.type_keys(":abc", "<C-f>")
  eq(child.fn.getcmdwintype(), ":")
end

T["<C-d> deletes the character under the cursor"] = function()
  child.type_keys(":abc", "<C-a>", "<C-d>")
  eq(e.cmdline(), { "bc", 1 })
end

T["<C-d> at the end lists completions"] = function()
  child.lua([[
    vim.api.nvim_create_user_command("Pick", function() end, {
      nargs = 1,
      complete = function()
        _G.completed = true
        return { "one" }
      end,
    })
  ]])
  child.type_keys(":Pick ", "<C-d>")
  eq(child.lua_get("_G.completed"), true)
  eq(e.cmdline(), { "Pick ", 6 })
end

T["<C-t> swaps the characters around the cursor"] = function()
  child.type_keys(":abcd", "<C-a>", "<C-f>", "<C-f>", "<C-t>")
  eq(e.cmdline(), { "acbd", 4 })
end

T["<C-t> at the end swaps the last two characters"] = function()
  child.type_keys(":abcd", "<C-t>")
  eq(e.cmdline(), { "abdc", 5 })
end

T["<C-k> deletes to the end"] = function()
  child.type_keys(":abc def", "<C-a>", "<M-f>", "<C-k>")
  eq(e.cmdline(), { "abc", 4 })
end

T["<C-u> deletes to the start and leaves registers alone"] = function()
  child.fn.setreg("-", "keep")
  child.type_keys(":abc def", "<M-b>", "<C-u>")
  eq(e.cmdline(), { "def", 1 })
  eq(child.fn.getreg("-"), "keep")
end

T["<C-w> deletes back to the previous space"] = function()
  child.type_keys(":foo bar.baz", "<C-w>")
  eq(e.cmdline(), { "foo ", 5 })
end

T["<M-p> deletes back one path segment"] = function()
  child.type_keys(":e /path/to/file", "<M-p>")
  eq(e.cmdline(), { "e /path/to/", 12 })
  child.type_keys("<M-p>")
  eq(e.cmdline(), { "e /path/", 9 })
end

T["<M-b> and <M-f> move by word"] = function()
  child.type_keys(":foo bar", "<M-b>")
  eq(e.cmdline(), { "foo bar", 5 })
  child.type_keys("<C-a>", "<M-f>")
  eq(e.cmdline(), { "foo bar", 4 })
end

T["<M-d> deletes the next word"] = function()
  child.type_keys(":foo bar", "<C-a>", "<M-d>")
  eq(e.cmdline(), { " bar", 1 })
end

T["<M-BS> and <M-C-h> delete the previous word"] = function()
  child.type_keys(":foo bar.baz", "<M-BS>")
  eq(e.cmdline(), { "foo bar.", 9 })
  child.type_keys("<M-C-h>")
  eq(e.cmdline(), { "foo ", 5 })
end

T["<M-u>, <M-l> and <M-c> change the case of the next word"] = function()
  child.type_keys(":foo BAR baz", "<C-a>", "<M-u>", "<M-l>", "<M-c>")
  eq(e.cmdline(), { "FOO bar Baz", 12 })
end

T["<M-.> inserts the last argument of earlier commands"] = function()
  child.fn.histadd("cmd", "edit foo.txt")
  child.fn.histadd("cmd", "write bar.txt")
  child.type_keys(":e ", "<M-.>")
  eq(e.cmdline(), { "e bar.txt", 10 })
  child.type_keys("<M-.>")
  eq(e.cmdline(), { "e foo.txt", 10 })
end

return T
