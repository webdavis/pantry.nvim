# pantry.nvim

pantry.nvim is a pantry of small Neovim features, called jars.

Each jar does one job that could have been a plugin of its own. You open the jars you want, and the
rest never load.

## What's in the pantry

| Jar                                 | What it does for you                                                                                                                          |
| ----------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| [rsi](docs/jars/rsi.md)             | Edit in insert mode and on the command line with your shell's readline keys, like `<C-a>` to go to the start and `<M-f>` to go forward a word |
| [linelimit](docs/jars/linelimit.md) | See a line getting too long: a faint mark near the limit, and `+N` once it is past                                                            |
| [jumps](docs/jars/jumps.md)         | Go to the next or previous function, block, diagnostic, merge conflict, or file in the same folder                                            |
| [focus](docs/jars/focus.md)         | Dim everything except the code around the cursor, and show more or less of it with a key                                                      |
| [markdown](docs/jars/markdown.md)   | Check off a task with one key, and move between checkboxes and code blocks                                                                    |
| [messages](docs/jars/messages.md)   | See every message again on one key, with its time and level. It also turns on Neovim's experimental message window                            |

Each jar's page lists its keys and options.

## Setup

### Requirements

- [Neovim](https://neovim.io) 0.12 or newer

### Install

Install pantry with every jar. To leave a jar out, remove its line.

With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "webdavis/pantry.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  opts = {
    rsi = {},
    linelimit = {},
    jumps = {},
    focus = {},
    markdown = {},
    messages = {},
  },
}
```

With Neovim's built-in plugin manager:

```lua
vim.pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/webdavis/pantry.nvim",
})

require("pantry").setup({
  rsi = {},
  linelimit = {},
  jumps = {},
  focus = {},
  markdown = {},
  messages = {},
})
```

### Map a key for focus

focus stays off until you turn it on, and it has no key of its own. Map one:

```lua
vim.keymap.set("n", "<leader>uf", function()
  require("pantry.focus").toggle()
end)
```

### Turn off a key or change an option

Some jars map keys that Neovim already uses. jumps takes `{`, `}`, `[[`, `]m` and `]s`, among
others.

To keep Neovim's meaning for a key, set it to `false` in that jar's `keys`:

```lua
require("pantry").setup({
  jumps = {
    keys = { ["[["] = false },
  },
})
```

Every other option goes in the jar's table the same way.

### Plugins and parsers that add more

Every jar loads without these plugins. Each one adds something:

| To get                                                          | What you need                                                                                                |
| --------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| jumps and focus in more languages                               | [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter), to install a parser for each language |
| `[[` to go up to the function or block you are in               | [nvim-treesitter-context](https://github.com/nvim-treesitter/nvim-treesitter-context)                        |
| Jumps by function, class, loop, argument and other text objects | [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects)                |
| The message history in a searchable picker                      | [snacks.nvim](https://github.com/folke/snacks.nvim)                                                          |

jumps and focus read your code through tree-sitter parsers. Neovim ships the parsers for Lua,
Markdown, C and Vim script. Install any other language with nvim-treesitter:

```vim
:TSInstall python
```

nvim-treesitter builds the parser on your machine. See
[what it requires](https://github.com/nvim-treesitter/nvim-treesitter#requirements).

### Check that it works

List the jars pantry has set up:

```vim
:checkhealth pantry
```

## Learn more

- [Developing pantry](docs/development.md): run the tests and the formatter

The reference for every jar is also inside Neovim:

```vim
:help pantry
```
