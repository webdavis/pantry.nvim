# pantry.nvim

pantry.nvim is a set of small Neovim modules in one plugin. Each module is off until you turn
it on. pantry.nvim needs Neovim 0.12 or newer and has no other dependencies.

## Install

With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "webdavis/pantry.nvim",
  lazy = false,
  opts = {
    rsi = {},
    linelimit = {},
  },
}
```

## Setup

Name a module in `setup` to turn it on. Pass `{ enabled = false }` to keep a module off. pantry
never loads a module that you do not name.

```lua
require("pantry").setup({
  rsi = {},
  linelimit = {},
})
```

Each module also works on its own:

```lua
require("pantry.rsi").setup({})
```

Run `:checkhealth pantry` to see which modules are on.

## Modules

### rsi

`pantry.rsi` adds readline editing keys to insert mode and the command line. These are the keys
that shells such as bash use. It replaces [vim-rsi](https://github.com/tpope/vim-rsi).

| Key | Insert mode | Command line |
|---|---|---|
| `<C-a>` | Go to the first non-blank character | Go to the start |
| `<C-e>` | Go to the end of the line | Neovim's own |
| `<C-b>` | Go left one character | Go left one character |
| `<C-f>` | Go right one character | Go right one character |
| `<C-d>` | Delete the character under the cursor | Delete the character under the cursor |
| `<C-k>` | Kill to the end of the line | Kill to the end |
| `<C-u>` | Kill back to the first non-blank character | Kill to the start |
| `<C-w>` | Kill back to the previous space | Kill back to the previous space |
| `<M-p>` | Kill back one path segment, up to the previous `/` or space | Kill back one path segment, up to the previous `/` or space |
| `<C-t>` | Neovim's own | Swap the two characters around the cursor |
| `<C-y>` | Neovim's own | Paste the latest kill |
| `<M-y>` | | After `<C-y>`, replace the paste with the next older kill |
| `<M-b>` | Go back one word | Go back one word |
| `<M-f>` | Go forward one word | Go forward one word |
| `<M-d>` | Kill the next word | Kill the next word |
| `<M-BS>`, `<M-C-h>` | Kill the previous word | Kill the previous word |
| `<M-u>` | Uppercase the next word | Uppercase the next word |
| `<M-l>` | Lowercase the next word | Lowercase the next word |
| `<M-c>` | Capitalize the next word | Capitalize the next word |
| `<M-.>` | | Insert the last argument of the previous command. Press it again for older commands |

Some keys keep Neovim's own meaning in certain places:

- At the end of a line, `<C-d>` removes one indent level in insert mode and lists completions on
  the command line.
- At the end of a line, `<C-f>` keeps Neovim's insert-mode meaning. On the command line it opens
  the command-line window.
- At the end of a line, insert-mode `<C-e>` inserts the character below the cursor.
- On a search line (`/` or `?`), `<C-t>` keeps Neovim's meaning.

A kill deletes text and saves it in a list called the kill ring. `<C-k>`, `<C-u>`, `<C-w>`, `<M-p>`,
`<M-d>`, `<M-BS>` and `<M-C-h>` kill text in both modes. `<C-y>` pastes the latest kill on the
command line. Kills do not change any register.

Insert-mode keys stay inside insert mode. `.` repeats the whole insert, and one `u` undoes it.

While a completion menu is open, `<C-e>`, `<C-k>` and `<C-y>` go to the menu. pantry checks
[blink.cmp](https://github.com/Saghen/blink.cmp) when it is loaded. Otherwise it checks
Neovim's built-in popup menu.

To turn off one key, set it to `false`:

```lua
require("pantry").setup({
  rsi = {
    keys = { ["<C-k>"] = false },
  },
})
```

### linelimit

`pantry.linelimit` shows how close each line is to a line length limit.

- A faint `│` appears just after the limit on lines that are within `near` columns of it. Shorter
  lines get nothing.
- A line that goes past the limit gets `+N` after its end. N is how many columns it is over.
- Text past the limit keeps its normal color.

pantry checks only the lines on the screen. It counts width in screen columns, so a tab or a wide
character counts as wide as it looks. Concealed text still counts.

The limit for a window comes from the first of these that is set:

1. The window's `colorcolumn`. pantry uses the first entry. `+1` means the limit is `textwidth`,
   and `81` means the limit is 80.
2. `textwidth`, when it is above 0.
3. `max_line_length` from an EditorConfig file.
4. The `filetypes` option.

If none of these is set, the window shows nothing.

While the module is on, pantry hides Neovim's own `colorcolumn` stripe in the windows it checks.
It still uses the `colorcolumn` value as the limit. `disable()` puts the stripe back.

pantry skips floating windows, buffers that have a `buftype` such as help or terminal buffers,
and the filetypes in `skip`.

| Option | Default | Meaning |
|---|---|---|
| `near` | `10` | How many columns before the limit a line starts to get the mark |
| `filetypes` | `{}` | A limit for each filetype, such as `{ lua = 120 }` |
| `skip` | `{ "help", "qf", "man", "terminal", "prompt" }` | Filetypes to leave alone |
| `enabled` | `true` | Set to `false` to keep the module off |

The mark uses the `PantryLineLimit` highlight, which links to `NonText`. The `+N` count uses
`PantryLineLimitOver`, which links to `DiagnosticVirtualTextWarn`. A colorscheme can set its own
colors for both.

```lua
require("pantry").setup({
  linelimit = {
    near = 5,
    filetypes = { lua = 120, markdown = 80 },
  },
})
```

`require("pantry.linelimit").disable()` turns the module off, and `enable()` turns it back on.

### jumps

`pantry.jumps` adds keys that move the cursor by the structure of the code. It reads the
structure from Neovim's built-in tree-sitter, so a language needs a tree-sitter parser for the
code keys to work. pantry does not install parsers.

| Keys | Mode | Moves to |
|---|---|---|
| `{` and `}` | Normal | One block level out or in |
| `]j` and `[j` | Normal, visual, operator-pending | The next or previous node at the same level |
| `]r` and `[r` | Normal, visual, operator-pending | The next or previous return |
| `]n` and `[n` | Normal | The next or previous merge-conflict marker |
| `` ]` `` and `` [` `` | Normal, visual, operator-pending, markdown only | The next or previous fenced code block |
| `]x` and `[x` | Normal, visual, operator-pending, markdown only | The next or previous checkbox |

Every key takes a count, and every jump goes into the jump list, so `<C-o>` goes back.

`{` goes to the first line of the block around the cursor. `2{` goes out two levels. `}` goes
back down the levels that `{` came out of. If you move the cursor another way or edit the
buffer first, `}` goes to the first block inside the block under the cursor. In a buffer with
no parser, `{` and `}` keep their paragraph motion. Visual and operator-pending `{` and `}` always
keep it.

pantry takes the list of blocks from
[nvim-treesitter-context](https://github.com/nvim-treesitter/nvim-treesitter-context) when it is
installed. Without it, pantry has its own list for Lua, Python, JavaScript, TypeScript, Go,
Rust, Swift, Bash, JSON, YAML, TOML and markdown.

`]j` and `[j` skip over anything nested and stop at the ends of the block. In JSON, YAML and
TOML they move between keys at one level and between the items of a list.

`]r` and `[r` use the `@return.outer` captures from
[nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects).
pantry adds its own captures for three languages:

- Rust: the last expression of a function body when it has no semicolon.
- Swift: a `return`, and the single expression body of a function that declares a return
  type. Closures are skipped.
- Bash: a `return`, and an `echo` or `printf` that is the last command of a function, unless
  it writes to stderr with `>&2`.

pantry also makes Swift `let` and `var` declarations into `@assignment` text objects, so
textobjects keys such as `]v` work on them.

`]n` and `[n` stop on lines that start with `<<<<<<<`, `=======` or `>>>>>>>`.

To turn off one key, set it to `false`:

```lua
require("pantry").setup({
  jumps = {
    keys = { ["]r"] = false },
  },
})
```

## Development

`make test` runs the tests with [mini.test](https://github.com/echasnovski/mini.nvim). The first
run clones mini.nvim, nvim-treesitter, nvim-treesitter-context and nvim-treesitter-textobjects
into `deps/` and builds the tree-sitter parsers the tests use there. Building the parsers needs
the `tree-sitter` CLI and a C compiler. The tests run with their own Neovim data directory under
`deps/`, so your own parsers and plugins are never used. `make format` formats the Lua files
with stylua.

## License

MIT
