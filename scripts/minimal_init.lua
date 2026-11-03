vim.opt.runtimepath:prepend(vim.fn.getcwd())
vim.opt.runtimepath:append(vim.fn.getcwd() .. "/deps/mini.nvim")
local data = vim.fn.stdpath("data")
local ts_dirs = vim.env.TS_DIRS
local dirs = ts_dirs and ts_dirs ~= "" and vim.split(ts_dirs, ":", { trimempty = true })
  or { data .. "/site", data .. "/lazy/nvim-treesitter-context", data .. "/lazy/nvim-treesitter-textobjects" }
for _, dir in ipairs(dirs) do
  if vim.uv.fs_stat(dir) then
    vim.opt.runtimepath:append(dir)
  end
end
require("mini.test").setup()
