return {
  {
    keys = { next = "]n", prev = "[n" },
    desc = { next = "Next conflict marker", prev = "Previous conflict marker" },
    modes = { "n" },
    find = require("pantry.jumps.conflicts").find,
  },
}
