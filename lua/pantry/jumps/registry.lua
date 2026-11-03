return {
  {
    keys = { next = "}", prev = "{" },
    desc = { next = "One block level in", prev = "One block level out" },
    modes = { "n" },
    find = require("pantry.jumps.levels").find,
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
}
