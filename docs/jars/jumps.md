# jumps

The jumps jar adds keys that move to the next or previous thing: a block, a node, a function, a
class, a diagnostic, a merge-conflict marker, a paragraph, or a file in the same folder.

## Turn it on

Add `jumps` to your setup:

```lua
require("pantry").setup({ jumps = {} })
```

## What it needs

The jumps jar needs one plugin, and two more plugins add keys. Without a plugin, the keys that need
it stay put.

| Plugin                                                                                        | What it gives you                                                       |
| --------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)                         | Installs the parser for each language. Needed.                          |
| [nvim-treesitter-context](https://github.com/nvim-treesitter/nvim-treesitter-context)         | `{` and `}` block kinds for more languages. `[[` needs it.              |
| [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects) | `]r` and `[r` returns for more languages. The text object keys need it. |

With lazy.nvim, list all three as dependencies:

```lua
{
  "webdavis/pantry.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-treesitter/nvim-treesitter-context",
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  opts = { jumps = {} },
}
```

## Keys

Every key takes a count. A jump from normal mode goes into the jump list, so `<C-o>` goes back.

| Keys          | Modes                            | Goes to                                                |
| ------------- | -------------------------------- | ------------------------------------------------------ |
| `{` and `}`   | Normal                           | One block level out or in                              |
| `]j` and `[j` | Normal, visual, operator-pending | The next or previous node at the same level            |
| `]r` and `[r` | Normal, visual, operator-pending | The next or previous return                            |
| `[[`          | Normal                           | Up to the header that nvim-treesitter-context shows    |
| `]c` and `[c` | Normal, visual, operator-pending | The next or previous class start, or diff change       |
| `]C` and `[C` | Normal, visual, operator-pending | The next or previous class end                         |
| `]m` and `[m` | Normal, visual, operator-pending | The next or previous function start                    |
| `]M` and `[M` | Normal, visual, operator-pending | The next or previous function end                      |
| `]l` and `[l` | Normal, visual, operator-pending | The next or previous loop start                        |
| `]L` and `[L` | Normal, visual, operator-pending | The next or previous loop end                          |
| `]s` and `[s` | Normal, visual, operator-pending | The next or previous local scope                       |
| `]z` and `[z` | Normal, visual, operator-pending | The next or previous fold                              |
| `]k` and `[k` | Normal, visual, operator-pending | The next or previous conditional                       |
| `]v` and `[v` | Normal, visual, operator-pending | The next or previous assignment                        |
| `],` and `[,` | Normal, visual, operator-pending | The next or previous argument                          |
| `]3` and `[3` | Normal, visual, operator-pending | The next or previous comment                           |
| `]n` and `[n` | Normal                           | The next or previous merge-conflict marker             |
| `]E` and `[E` | Normal                           | The next or previous diagnostic error                  |
| `]W` and `[W` | Normal                           | The next or previous diagnostic warning                |
| `]P` and `[P` | Normal, visual, operator-pending | The next or previous paragraph                         |
| `]f` and `[f` | Normal                           | The next or previous file in the current file's folder |

## Neovim keys it replaces

These keys replace Neovim's own meaning:

- `]f` and `[f` no longer edit the file name under the cursor.
- `]P` and `[P` no longer put text with the indent adjusted.
- `]c` and `[c` go to the next or previous change only in a diff window.
- `]s` and `[s` no longer go to a misspelled word.
- `]z` and `[z` no longer go to the end or start of the open fold.
- `]l`, `[l`, `]L`, and `[L` no longer move through the location list.
- `]m`, `[m`, `]M`, `[M`, and `[[` no longer use Neovim's method and section motions.

Set a key to `false` in `keys` to keep Neovim's meaning.

A buffer-local mapping still wins over jumps. Some filetype plugins, such as Python's, map `]m`,
`[m`, `]M`, `[M`, and `[[` in each buffer. To stop them, set this before they load:

```lua
vim.g.no_plugin_maps = true
```

## Move between block levels

`{` and `}` move out of and back into the blocks around the cursor:

- `{` goes to the first line of the block around the cursor, and `2{` goes out two levels.
- `}` goes back down the levels that `{` came out of.
- If you move the cursor another way or edit the buffer first, `}` goes to the first block inside
  the block under the cursor.
- In visual and operator-pending mode, `{` and `}` keep their paragraph motion.

## Move between nodes at the same level

`]j` and `[j` skip over anything nested and stop at the ends of the block. In JSON, YAML, and TOML
they move between keys at one level and between the items of a list.

## Move between returns

`]r` and `[r` stop on the `@return.outer` captures from nvim-treesitter-textobjects. pantry adds its
own captures for three languages:

- Rust: the last expression of a function body when it has no semicolon.
- Swift: a `return`, and the single-expression body of a function that declares a return type. The
  single-expression body of a closure does not count.
- Bash: a `return`, and an `echo` or `printf` that is the last command of a function, unless it
  writes to stderr with `>&2`.

## Move between text objects

The text object keys call the move functions of nvim-treesitter-textobjects:

| Keys          | Function                                 | Captures                                   | Query group |
| ------------- | ---------------------------------------- | ------------------------------------------ | ----------- |
| `]c` and `[c` | `goto_next_start`, `goto_previous_start` | `@class.outer`, `@class.inner`             | textobjects |
| `]C` and `[C` | `goto_next_end`, `goto_previous_end`     | `@class.outer`, `@class.inner`             | textobjects |
| `]m` and `[m` | `goto_next_start`, `goto_previous_start` | `@function.outer`, `@function.inner`       | textobjects |
| `]M` and `[M` | `goto_next_end`, `goto_previous_end`     | `@function.outer`, `@function.inner`       | textobjects |
| `]l` and `[l` | `goto_next_start`, `goto_previous_start` | `@loop.outer`, `@loop.inner`               | textobjects |
| `]L` and `[L` | `goto_next_end`, `goto_previous_end`     | `@loop.outer`, `@loop.inner`               | textobjects |
| `]s` and `[s` | `goto_next`, `goto_previous`             | `@local.scope`                             | locals      |
| `]z` and `[z` | `goto_next`, `goto_previous`             | `@fold`                                    | folds       |
| `]k` and `[k` | `goto_next`, `goto_previous`             | `@conditional.outer`, `@conditional.inner` | textobjects |
| `]v` and `[v` | `goto_next_start`, `goto_previous_start` | `@assignment.outer`                        | textobjects |
| `],` and `[,` | `goto_next_start`, `goto_previous_start` | `@parameter.inner`                         | textobjects |
| `]3` and `[3` | `goto_next_start`, `goto_previous_start` | `@comment.outer`                           | textobjects |

In a diff window, `]c` and `[c` run Neovim's own `]c` and `[c` and go to the next or previous
change. In operator-pending mode, nvim-treesitter-textobjects makes the move include the character
it lands on.

## Jump to Swift assignments

pantry makes Swift `let` and `var` declarations into `@assignment` text objects, so `]v` and other
keys that use `@assignment` work on them:

- The name is `@assignment.lhs`.
- The value is `@assignment.rhs`.

## Move up to the context

`[[` goes to the header line that nvim-treesitter-context shows above the cursor, and `2[[` goes up
two headers. `]]` keeps Neovim's meaning.

## Move between diagnostics

`]E` and `[E` stop only on errors. `]W` and `[W` stop only on warnings.

## Move between paragraphs

`]P` and `[P` run Neovim's `}` and `{` paragraph motions in every mode. They exist because `{` and
`}` are block level jumps in normal mode.

## Move between files in a folder

`]f` and `[f` open the next or previous file in the folder of the current file. In an unnamed buffer
they use the current directory.

- Names sort with digits compared as numbers, so `test2` comes before `test10`.
- Images, PDFs, archives, audio, video, fonts, lock files, swap files, `.DS_Store`,
  `lazy-lock.json`, `package-lock.json`, and `pnpm-lock.yaml` are skipped.
- Files that git ignores are skipped. Outside a git repository, no file is skipped for this.
- Folders are skipped. Links to files are kept.
- A buffer whose file is not in the list, such as a new file, sits between the names that sort
  around it.
- A jump past either end stops at the first or last file.

Each jump shows the position and the name, such as `4/12 init.lua`. A jump that cannot go further
adds `(first file)` or `(last file)`.

## Which keys need a parser

These keys need a tree-sitter parser for the buffer's language: `{`, `}`, `]j`, `[j`, `]r`, `[r`,
`[[`, and the text object keys. The other keys work in any buffer.

- In a buffer with no parser, `{` and `}` keep their paragraph motion, and the other keys that need
  a parser stay put.
- `{` and `}` take the list of block kinds from nvim-treesitter-context when it is installed.
- Without it, pantry uses its own list for Lua, Python, JavaScript, TypeScript, Go, Rust, Swift,
  Bash, JSON, YAML, TOML, and markdown. In markdown a block is a heading's section.

## Keys that moved to the markdown jar

The code block keys `` ]` `` and `` [` `` and the checkbox keys `]x` and `[x` now live in the
[markdown](markdown.md) jar. To turn one off, set it in `markdown` in place of `jumps`.

Before:

```lua
require("pantry").setup({ jumps = { keys = { ["]x"] = false } } })
```

Now:

```lua
require("pantry").setup({ markdown = { keys = { ["]x"] = false } } })
```

## Options

The jumps jar has one option.

| Option | Default | Meaning          |
| ------ | ------- | ---------------- |
| `keys` | `{}`    | Keys to turn off |

A key set to `false` keeps Neovim's own meaning. The other key of the pair stays on. This turns off
`]r`:

```lua
require("pantry").setup({
  jumps = {
    keys = { ["]r"] = false },
  },
})
```
