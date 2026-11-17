local disk = require("pantry.disk")

local M = {}

local vanished = function(ctx)
  return ctx.own and disk.state(ctx.buf) == "gone"
end

M.before = function(ctx)
  ctx.vanished = vanished(ctx)
end

M.after = function(ctx)
  if ctx.vanished then
    ctx.warn(("%s was gone from disk, and this save brought it back"):format(ctx.name))
  end
end

M.explain = function(ctx)
  return vanished(ctx) and ("%s is gone from disk, so a save would bring it back."):format(ctx.name)
end

return M
