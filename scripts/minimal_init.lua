local root = vim.fn.getcwd()
vim.opt.runtimepath:prepend(root)
for _, dep in ipairs({ "mini.nvim", "nvim-treesitter", "nvim-treesitter-context", "nvim-treesitter-textobjects" }) do
  vim.opt.runtimepath:append(root .. "/deps/" .. dep)
end
require("nvim-treesitter").setup({ install_dir = root .. "/deps/parsers" })
require("mini.test").setup()
for _, name in ipairs({ "GIT_DIR", "GIT_WORK_TREE", "GIT_INDEX_FILE" }) do
  vim.env[name] = nil
end
