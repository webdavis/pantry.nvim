# pantry.nvim

pantry.nvim is a bundle of small Neovim jars. Each jar is off until you turn it on. pantry needs
Neovim 0.12 or newer and has no dependencies, except the tree-sitter parsers that jumps uses.

## Install

With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "webdavis/pantry.nvim",
  lazy = false,
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  opts = { rsi = {}, linelimit = {}, jumps = {} },
}
```

Only jumps needs nvim-treesitter. Leave it out if you do not use jumps.

## Setup

Name a jar in `setup` to turn it on. Pass `{ enabled = false }` to keep a jar off. pantry never
loads a jar that you do not name.

```lua
require("pantry").setup({
  rsi = {},
  linelimit = { enabled = false },
  jumps = {},
})
```

Each jar also works on its own:

```lua
require("pantry.rsi").setup()
```

Run `:checkhealth pantry` to see which jars are on.

## Jars

- [rsi](docs/jars/rsi.md) adds readline editing keys to insert mode and the command line.
- [linelimit](docs/jars/linelimit.md) marks lines that come close to a line length limit.
- [jumps](docs/jars/jumps.md) adds keys that move the cursor by the structure of the code.

## Development

`make test` runs the tests with [mini.test](https://github.com/echasnovski/mini.nvim). The first
run clones mini.nvim, nvim-treesitter, nvim-treesitter-context and nvim-treesitter-textobjects
into `deps/` and builds the tree-sitter parsers the tests use there. Building the parsers needs
the `tree-sitter` CLI and a C compiler. The tests run with their own Neovim data directory under
`deps/`, so your own parsers and plugins are never used. `make format` formats the Lua files
with stylua.

## License

MIT
