# Developing pantry

## Requirements

- [Neovim](https://neovim.io) 0.12 or newer
- [just](https://github.com/casey/just)
- [stylua](https://github.com/JohnnyMorganz/StyLua)
- The [tree-sitter CLI](https://github.com/tree-sitter/tree-sitter/blob/master/crates/cli/README.md)
- A C compiler

## Run the tests

Run every test with [mini.test](https://github.com/echasnovski/mini.nvim):

```bash
just test
```

The first run sets up `deps/`:

- It clones mini.nvim, nvim-treesitter, nvim-treesitter-context and nvim-treesitter-textobjects.
- It builds the tree-sitter parsers the tests use. This is what needs the tree-sitter CLI and the C
  compiler.

The tests use their own Neovim data directory under `deps/`, so they never touch your own parsers
and plugins.

## Format the code

Format the Lua files:

```bash
just format
```

## Pull requests

Every pull request runs the tests and the format check on GitHub. Both must pass before it can
merge.
