local textobjects = require("pantry.jumps.textobjects")
local mover = textobjects.mover

local textobject = function(next, prev, what, move)
  return {
    keys = { next = next, prev = prev },
    desc = { next = "Next " .. what, prev = "Previous " .. what },
    modes = { "n", "x", "o" },
    move = move,
  }
end

local class = { "@class.outer", "@class.inner" }
local func = { "@function.outer", "@function.inner" }
local loop = { "@loop.outer", "@loop.inner" }
local conditional = { "@conditional.outer", "@conditional.inner" }

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
  textobject("]c", "[c", "class start or diff change", textobjects.class_starts_or_changes),
  textobject("]C", "[C", "class end", mover("_end", class)),
  textobject("]m", "[m", "function start", mover("_start", func)),
  textobject("]M", "[M", "function end", mover("_end", func)),
  textobject("]l", "[l", "loop start", mover("_start", loop)),
  textobject("]L", "[L", "loop end", mover("_end", loop)),
  textobject("]s", "[s", "local scope", mover("", "@local.scope", "locals")),
  textobject("]z", "[z", "fold", mover("", "@fold", "folds")),
  textobject("]k", "[k", "conditional", mover("", conditional)),
  textobject("]v", "[v", "assignment", mover("_start", "@assignment.outer")),
  textobject("],", "[,", "argument", mover("_start", "@parameter.inner")),
  textobject("]3", "[3", "comment", mover("_start", "@comment.outer")),
}
