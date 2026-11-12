# markdown

The markdown jar adds keys to markdown buffers. One key turns a line into a task and checks or opens
it. The other keys move between checkboxes and code blocks.

## Turn it on

Add `markdown` to your setup:

```lua
require("pantry").setup({ markdown = {} })
```

## What it needs

The jump keys need the markdown tree-sitter parser. Neovim ships it, and
[nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) can install a newer one:

```vim
:TSInstall markdown
```

## Keys

The keys exist only in markdown buffers.

| Keys                  | Modes                            | Action                                |
| --------------------- | -------------------------------- | ------------------------------------- |
| `<C-CR>`              | Normal, insert                   | Toggle the task on the current line   |
| `]x` and `[x`         | Normal, visual, operator-pending | Go to the next or previous checkbox   |
| `` ]` `` and `` [` `` | Normal, visual, operator-pending | Go to the next or previous code block |

## Toggle a task

`<C-CR>` changes the current line by what it holds:

- A plain line becomes `- [ ] line`. The indent stays.
- A list item that starts with `- `, `* `, `+ `, or a number and `. ` or `) `, gets a `[ ] ` box.
- A task with `[ ]` becomes `[x]`.
- A task with `[x]` or `[X]` becomes `[ ]`.

The cursor stays on the same character of the text. In insert mode you keep typing where you were.

## Move through checkboxes and code blocks

The jump keys stop on these lines:

- `]x` and `[x` stop on each checkbox, checked or not, and skip text inside code blocks.
- `` ]` `` and `` [` `` stop on the first line of each fenced code block.

After a jump:

- The cursor goes to the first character of the line that is not a space.
- Every jump key takes a count.
- A jump from normal mode goes into the jump list, so `<C-o>` goes back.

These four keys used to be part of the jumps jar. To turn one off now, set it in `markdown`, not in
`jumps`.

## Options

The markdown jar has one option.

| Option | Default | Meaning          |
| ------ | ------- | ---------------- |
| `keys` | `{}`    | Keys to turn off |

A key set to `false` keeps Neovim's own meaning. The other keys stay on. This turns off `<C-CR>`:

```lua
require("pantry").setup({
  markdown = {
    keys = { ["<C-CR>"] = false },
  },
})
```
