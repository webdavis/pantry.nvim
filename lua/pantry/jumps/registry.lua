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
    keys = { next = "]P", prev = "[P" },
    desc = { next = "Next paragraph", prev = "Previous paragraph" },
    modes = { "n", "x", "o" },
    move = require("pantry.jumps.paragraphs").move,
  },
  {
    keys = { next = "]E", prev = "[E" },
    desc = { next = "Next error", prev = "Previous error" },
    modes = { "n" },
    move = require("pantry.jumps.diagnostics").errors,
  },
  {
    keys = { next = "]W", prev = "[W" },
    desc = { next = "Next warning", prev = "Previous warning" },
    modes = { "n" },
    move = require("pantry.jumps.diagnostics").warnings,
  },
  {
    keys = { next = "]f", prev = "[f" },
    desc = { next = "Next file in folder", prev = "Previous file in folder" },
    modes = { "n" },
    move = require("pantry.jumps.files").move,
  },
}
