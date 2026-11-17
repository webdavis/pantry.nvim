local M = {}

local missing_folder = function(ctx)
  local folder = vim.fs.dirname(ctx.path)
  return vim.fn.isdirectory(folder) == 0 and folder or nil
end

M.before = function(ctx)
  local folder = missing_folder(ctx)
  if folder and vim.fn.mkdir(folder, "p") == 1 then
    ctx.note("made the folder " .. folder)
  end
end

M.explain = function(ctx)
  local folder = missing_folder(ctx)
  return folder and ("It would make the folder %s."):format(folder)
end

return M
