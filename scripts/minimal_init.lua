local root = vim.fn.getcwd()
vim.opt.runtimepath:prepend(root)
for _, dep in ipairs({ "mini.nvim", "nvim-treesitter", "nvim-treesitter-context", "nvim-treesitter-textobjects" }) do
  vim.opt.runtimepath:append(root .. "/deps/" .. dep)
end
require("nvim-treesitter").setup({ install_dir = root .. "/deps/parsers" })
require("mini.test").setup()
