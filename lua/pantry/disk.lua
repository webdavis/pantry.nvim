local M = {}

local group = "pantry.disk"

local stamp = function(path)
  local stat = vim.uv.fs_stat(path)
  return stat and ("%d.%d"):format(stat.mtime.sec, stat.mtime.nsec)
end

local remember = function(buf)
  vim.b[buf].pantry_disk = stamp(vim.api.nvim_buf_get_name(buf))
end

-- Neovim keeps the time it last read or wrote a file to itself, so pantry keeps its own.
M.watch = function()
  vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "BufFilePost" }, {
    group = vim.api.nvim_create_augroup(group, {}),
    callback = function(event)
      remember(event.buf)
    end,
  })
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.b[buf].pantry_disk == nil then
      remember(buf)
    end
  end
end

---@return "same"|"changed"|"gone"|"new"
M.state = function(buf)
  local now = stamp(vim.api.nvim_buf_get_name(buf))
  local seen = vim.b[buf].pantry_disk
  if not now then
    return seen and "gone" or "new"
  end
  return seen == now and "same" or "changed"
end

M.writable = function(buf)
  return not vim.bo[buf].readonly and vim.fn.filewritable(vim.api.nvim_buf_get_name(buf)) == 1
end

return M
