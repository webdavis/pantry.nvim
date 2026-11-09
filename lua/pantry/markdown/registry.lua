local find = require("pantry.markdown.find")
local jump = require("pantry.markdown.jump")

local motion = { "n", "x", "o" }

return {
  { lhs = "]x", modes = motion, desc = "Next checkbox", action = jump.to(find.checkboxes, 1) },
  { lhs = "[x", modes = motion, desc = "Previous checkbox", action = jump.to(find.checkboxes, -1) },
  { lhs = "]`", modes = motion, desc = "Next code block", action = jump.to(find.fences, 1) },
  { lhs = "[`", modes = motion, desc = "Previous code block", action = jump.to(find.fences, -1) },
}
