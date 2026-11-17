local M = {}

-- These keys sit beside Enter, so a file named only with them is almost always a slip.
local looks_like_a_slip = function(name)
  return #name <= 2 and name:match("^[%]%[\\;'`=]+$") ~= nil
end

M.before = function(ctx)
  ctx.slip = not ctx.own and not ctx.bang and not ctx.existed and ctx.buffer_name ~= "" and looks_like_a_slip(ctx.name)
end

M.after = function(ctx)
  if not ctx.slip then
    return
  end
  vim.fn.delete(ctx.path)
  -- The stray write is still running here, and a save made inside it leaves the buffer marked changed.
  vim.schedule(function()
    local saved, err = pcall(vim.api.nvim_buf_call, ctx.buf, function()
      vim.cmd("silent write")
    end)
    local own = vim.fs.basename(ctx.buffer_name)
    if saved then
      ctx.note(("saved %s, not a new file named %s. Use :w! to write that name"):format(own, ctx.name))
    else
      ctx.warn(("did not write a new file named %s, and could not save %s: %s"):format(ctx.name, own, err))
    end
  end)
end

return M
