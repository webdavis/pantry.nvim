local edits = require("pantry.rsi.edits")
local ring = require("pantry.rsi.killring").new()
local insert = require("pantry.rsi.insert").new(ring)
local cmdline = require("pantry.rsi.cmdline").new(ring)

local cedit = function()
  return vim.o.cedit
end

return {
  {
    lhs = "<C-a>",
    desc = "Start of line",
    insert = insert.edit(edits.first_nonblank),
    cmdline = cmdline.edit(edits.start),
  },
  { lhs = "<C-e>", desc = "End of line", insert = insert.edit(edits.end_of_line), yields_to_menu = true },
  { lhs = "<C-b>", desc = "Back one character", insert = insert.edit(edits.left), cmdline = cmdline.edit(edits.left) },
  {
    lhs = "<C-f>",
    desc = "Forward one character",
    insert = insert.edit(edits.right),
    cmdline = cmdline.edit(edits.right, cedit),
  },
  {
    lhs = "<C-d>",
    desc = "Delete character",
    insert = insert.edit(edits.delete_char),
    cmdline = cmdline.edit(edits.delete_char),
  },
  {
    lhs = "<C-k>",
    desc = "Kill to end of line",
    insert = insert.edit(edits.kill_to_end),
    cmdline = cmdline.edit(edits.kill_to_end),
    yields_to_menu = true,
  },
  {
    lhs = "<C-u>",
    desc = "Kill to start of line",
    insert = insert.edit(edits.kill_to_indent),
    cmdline = cmdline.edit(edits.kill_to_start),
  },
  {
    lhs = "<C-w>",
    desc = "Kill back to the previous space",
    insert = insert.edit(edits.kill_blank_word_back),
    cmdline = cmdline.edit(edits.kill_blank_word_back),
  },
  {
    lhs = "<M-p>",
    desc = "Kill back one path segment",
    insert = insert.edit(edits.kill_path_back),
    cmdline = cmdline.edit(edits.kill_path_back),
  },
  { lhs = "<C-t>", desc = "Swap characters", cmdline = cmdline.transpose },
  { lhs = "<C-y>", desc = "Paste the latest kill", cmdline = cmdline.yank, yields_to_menu = true },
  { lhs = "<M-y>", desc = "Replace the paste with an older kill", cmdline = cmdline.yank_pop },
  {
    lhs = "<M-b>",
    desc = "Back one word",
    insert = insert.edit(edits.word_back),
    cmdline = cmdline.edit(edits.word_back),
  },
  {
    lhs = "<M-f>",
    desc = "Forward one word",
    insert = insert.edit(edits.word_forward),
    cmdline = cmdline.edit(edits.word_forward),
  },
  {
    lhs = "<M-d>",
    desc = "Kill next word",
    insert = insert.edit(edits.kill_word_forward),
    cmdline = cmdline.edit(edits.kill_word_forward),
  },
  {
    lhs = "<M-BS>",
    desc = "Kill previous word",
    insert = insert.edit(edits.kill_word_back),
    cmdline = cmdline.edit(edits.kill_word_back),
  },
  {
    lhs = "<M-C-h>",
    desc = "Kill previous word",
    insert = insert.edit(edits.kill_word_back),
    cmdline = cmdline.edit(edits.kill_word_back),
  },
  {
    lhs = "<M-u>",
    desc = "Uppercase next word",
    insert = insert.edit(edits.upcase_word),
    cmdline = cmdline.edit(edits.upcase_word),
  },
  {
    lhs = "<M-l>",
    desc = "Lowercase next word",
    insert = insert.edit(edits.downcase_word),
    cmdline = cmdline.edit(edits.downcase_word),
  },
  {
    lhs = "<M-c>",
    desc = "Capitalize next word",
    insert = insert.edit(edits.capitalize_word),
    cmdline = cmdline.edit(edits.capitalize_word),
  },
  { lhs = "<M-.>", desc = "Insert the last argument of an earlier command", cmdline = cmdline.last_arg },
}
