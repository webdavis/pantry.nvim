local M = {}

M.after = function(ctx)
  if ctx.own and vim.bo[ctx.buf].filetype == "" then
    vim.api.nvim_buf_call(ctx.buf, function()
      vim.cmd("filetype detect")
    end)
  end
end

return M
