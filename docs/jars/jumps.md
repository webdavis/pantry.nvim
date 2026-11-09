# jumps

`pantry.jumps` adds keys that move the cursor by the structure of the code.

## Install

jumps needs nvim-treesitter to install parsers. The other two plugins are optional.

```lua
{
  "webdavis/pantry.nvim",
  lazy = false,
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-treesitter/nvim-treesitter-context",
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  opts = { jumps = {} },
}
```

- nvim-treesitter-context gives `{` and `}` block kinds for more languages.
- nvim-treesitter-textobjects gives `]r` and `[r` returns for more languages.

## Keys

| Keys | Modes | Goes to |
|---|---|---|
| `{` and `}` | Normal | One block level out or in |
| `]j` and `[j` | Normal, visual, operator-pending | The next or previous node at the same level |
| `]r` and `[r` | Normal, visual, operator-pending | The next or previous return |
| `]n` and `[n` | Normal | The next or previous merge-conflict marker |
| `]E` and `[E` | Normal | The next or previous diagnostic error |
| `]W` and `[W` | Normal | The next or previous diagnostic warning |
| `]f` and `[f` | Normal | The next or previous file in the current file's folder |
| `]P` and `[P` | Normal, visual, operator-pending | The next or previous paragraph, like `}` and `{` |

A merge-conflict marker is a line that starts with `<<<<<<<`, `|||||||`, `=======`, or `>>>>>>>`.
Every key takes a count. A jump from normal mode goes into
the jump list, so `<C-o>` goes back.

## Move between block levels

`{` goes to the first line of the block around the cursor, and `2{` goes out two levels. `}` goes
back down the levels that `{` came out of. If you move the cursor another way or edit the buffer
first, `}` goes to the first block inside the block under the cursor. In visual and
operator-pending mode, `{` and `}` keep their paragraph motion.

## Move between nodes at the same level

`]j` and `[j` skip over anything nested and stop at the ends of the block. In JSON, YAML, and TOML
they move between keys at one level and between the items of a list.

## Move between returns

`]r` and `[r` stop on the `@return.outer` captures from nvim-treesitter-textobjects. pantry adds
its own captures for three languages:

- Rust: the last expression of a function body when it has no semicolon.
- Swift: a `return`, and the single-expression body of a function that declares a return type.
  The single-expression body of a closure does not count.
- Bash: a `return`, and an `echo` or `printf` that is the last command of a function, unless it
  writes to stderr with `>&2`.

## Markdown keys

The code block keys `` ]` `` and `` [` `` and the checkbox keys `]x` and `[x` now live in the
[markdown](markdown.md) jar. `jumps = { keys = { ["]x"] = false } }` becomes
`markdown = { keys = { ["]x"] = false } }`.

## Swift assignments

pantry makes Swift `let` and `var` declarations into `@assignment` text objects. The name is
`@assignment.lhs` and the value is `@assignment.rhs`. Keys from nvim-treesitter-textobjects that
use `@assignment`, such as `]v`, then work on them.

## What needs a parser

Every key except `]n` and `[n` needs a tree-sitter parser for the buffer's language. In a buffer
with no parser, `{` and `}` keep their paragraph motion, and the other keys stay put.

`{` and `}` take the list of block kinds from nvim-treesitter-context when it is installed.
Without it, pantry uses its own list for Lua, Python, JavaScript, TypeScript, Go, Rust, Swift,
Bash, JSON, YAML, TOML, and markdown. In markdown a block is a heading's section.

## Options

| Option | Default | Meaning |
|---|---|---|
| `keys` | `{}` | Keys to turn off |

A key set to `false` keeps Neovim's own meaning. The other key of the pair stays on.

```lua
require("pantry").setup({
  jumps = {
    keys = { ["]r"] = false },
  },
})
```
