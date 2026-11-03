local Helpers = require("tests.helpers")
local child, hooks = Helpers.rsi_child()
local e = Helpers.editing(child)
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({ hooks = hooks })

T["<C-a> moves to the first non-blank character"] = function()
  e.lines({ "    foo bar" })
  child.type_keys("A", "<C-a>", "X")
  eq(e.line(), "    Xfoo bar")
end

T["<C-e> moves to the end of the line"] = function()
  e.lines({ "foo bar" })
  child.type_keys("0i", "<C-e>", "X")
  eq(e.line(), "foo barX")
end

T["<C-b> moves left one character"] = function()
  e.lines({ "abc" })
  child.type_keys("A", "<C-b>", "X")
  eq(e.line(), "abXc")
end

T["<C-b> on a blank first line stays on the line"] = function()
  e.lines({ "" })
  child.type_keys("i", "<C-b>", "X", "<Esc>")
  eq(e.buffer(), { "X" })
end

T["<C-f> moves right one character"] = function()
  e.lines({ "abc" })
  child.type_keys("0i", "<C-f>", "X")
  eq(e.line(), "aXbc")
end

T["<C-f> at the end of the line keeps its Neovim meaning"] = function()
  child.o.indentkeys = ""
  e.lines({ "abc" })
  child.type_keys("A", "<C-f>")
  eq(e.line(), "abc\6")
end

T["<C-d> deletes the character under the cursor"] = function()
  e.lines({ "abc" })
  child.type_keys("0i", "<C-d>")
  eq(e.line(), "bc")
end

T["<C-d> at the end of the line removes one indent level"] = function()
  e.lines({ "\tabc" })
  child.type_keys("A", "<C-d>")
  eq(e.line(), "abc")
end

T["<C-k> deletes to the end of the line"] = function()
  e.lines({ "foo bar" })
  child.type_keys("0wi", "<C-k>", "X")
  eq(e.line(), "foo X")
end

T["<M-b> and <M-f> move by word"] = function()
  e.lines({ "foo bar" })
  child.type_keys("A", "<M-b>", "X", "<Esc>")
  eq(e.line(), "foo Xbar")
  child.type_keys("0i", "<M-f>", "Y")
  eq(e.line(), "fooY Xbar")
end

T["<M-d> deletes the next word"] = function()
  e.lines({ "foo bar" })
  child.type_keys("0i", "<M-d>")
  eq(e.line(), " bar")
end

T["<M-BS> and <M-C-h> delete the previous word"] = function()
  e.lines({ "foo bar.baz" })
  child.type_keys("A", "<M-BS>")
  eq(e.line(), "foo bar.")
  child.type_keys("<M-C-h>")
  eq(e.line(), "foo ")
end

T["<C-w> deletes back to the previous space"] = function()
  e.lines({ "foo bar.baz  " })
  child.type_keys("A", "<C-w>")
  eq(e.line(), "foo ")
end

T["<M-p> deletes back one path segment"] = function()
  e.lines({ "see /path/to/file" })
  child.type_keys("A", "<M-p>")
  eq(e.line(), "see /path/to/")
  child.type_keys("<M-p>")
  eq(e.line(), "see /path/")
  child.type_keys("<M-p>", "<M-p>")
  eq(e.line(), "see ")
  child.type_keys("<M-p>")
  eq(e.line(), "")
end

T["<C-u> deletes back to the first non-blank character"] = function()
  e.lines({ "  foo bar" })
  child.type_keys("A", "<C-u>")
  eq(e.line(), "  ")
end

T["<M-u>, <M-l> and <M-c> change the case of the next word"] = function()
  e.lines({ "foo BAR baz" })
  child.type_keys("0i", "<M-u>", "<M-l>", "<M-c>", "!")
  eq(e.line(), "FOO bar Baz!")
end

T["case keys start from the cursor inside a word"] = function()
  e.lines({ "foo" })
  child.type_keys("0li", "<M-u>")
  eq(e.line(), "fOO")
end

T["word keys count multibyte characters as one"] = function()
  e.lines({ "één twee" })
  child.type_keys("A", "<M-b>", "<M-b>", "<M-d>", "X")
  eq(e.line(), "X twee")
end

T["dot repeats an insert that moved by word"] = function()
  e.lines({ "", "" })
  child.type_keys("i", "foo", "<M-b>", "bar", "<Esc>", "j", ".")
  eq(e.buffer(), { "barfoo", "barfoo" })
end

T["dot repeats an insert that deleted and changed case"] = function()
  e.lines({ "abc def ghi", "abc def ghi" })
  child.type_keys("0i", "<M-d>", "<M-u>", "<C-a>", "X", "<Esc>", "j0", ".")
  eq(e.buffer(), { " XDEF ghi", " XDEF ghi" })
end

T["one undo reverts the whole insert"] = function()
  e.lines({ "abc def" })
  child.type_keys("A", "<C-a>", "<M-d>", "<C-e>", "<M-BS>", "X", "<Esc>", "u")
  eq(e.buffer(), { "abc def" })
end

return T
