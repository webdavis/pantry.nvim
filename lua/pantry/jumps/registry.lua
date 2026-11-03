return {
  {
    keys = { next = "}", prev = "{" },
    desc = { next = "One block level in", prev = "One block level out" },
    modes = { "n" },
    find = require("pantry.jumps.levels").find,
  },
  {
    keys = { next = "]j", prev = "[j" },
    desc = { next = "Next node at this level", prev = "Previous node at this level" },
    modes = { "n", "x", "o" },
    find = require("pantry.jumps.siblings").find,
  },
  {
    keys = { next = "]r", prev = "[r" },
    desc = { next = "Next return", prev = "Previous return" },
    modes = { "n", "x", "o" },
    find = require("pantry.jumps.returns").find,
  },
  {
    keys = { next = "]n", prev = "[n" },
    desc = { next = "Next conflict marker", prev = "Previous conflict marker" },
    modes = { "n" },
    find = require("pantry.jumps.conflicts").find,
  },
  {
    keys = { next = "]`", prev = "[`" },
    desc = { next = "Next code block", prev = "Previous code block" },
    modes = { "n", "x", "o" },
    filetype = "markdown",
    find = require("pantry.jumps.markdown").fences,
  },
  {
    keys = { next = "]x", prev = "[x" },
    desc = { next = "Next checkbox", prev = "Previous checkbox" },
    modes = { "n", "x", "o" },
    filetype = "markdown",
    find = require("pantry.jumps.markdown").checkboxes,
  },
}
