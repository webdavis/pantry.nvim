# focus

The focus jar dims every line outside the code around the cursor. While focus is on, two keys show
more or less of the code. For example, in a JSON file you can light only the current `key: value`
line, then the object around it, then the whole file.

The focus jar is off until you turn it on. It needs Neovim 0.12 or newer.

## What it lights

The focus jar reads the structure of the buffer from Neovim's built-in tree-sitter. Each level
lights one tree-sitter node and dims the rest:

- Level 0 is the line under the cursor, such as a statement in Lua or a `key: value` pair in JSON.
- Each level up lights the next node that covers more lines. A node that covers the same lines as
  the one below it is skipped, so every key press changes what you see.
- The last level is the whole buffer.

When you turn focus on, it lights the first block around the cursor that spans more than one line.
The level stays the same when you move the cursor, and the lit lines follow the cursor.

A buffer with no tree-sitter parser has two levels. Level 0 lights the paragraph under the cursor.
Paragraphs are separated by blank lines. Level 1 lights the whole buffer.

## Keys

The keys work in normal mode. They exist only while focus is on, and only in the buffers you visit
while it is on. Turning focus off removes them.

| Key | Action |
| --- | --- |
| `<M-o>` | Show more: one level out. |
| `<M-i>` | Show less: one level in. |

The focus jar has no key to turn it on. Map `toggle()` to a key of your own:

```lua
vim.keymap.set("n", "<leader>uf", require("pantry.focus").toggle)
```

## Functions

- `require("pantry.focus").enable()` turns focus on.
- `require("pantry.focus").disable()` turns focus off and lights every line.
- `require("pantry.focus").toggle()` turns focus on when it is off, and off when it is on.
- `require("pantry.focus").widen()` lights one level more.
- `require("pantry.focus").narrow()` lights one level less.

`widen()` and `narrow()` do nothing while focus is off.

## Options

| Option | Default | Meaning |
| --- | --- | --- |
| `keys` | `{}` | Set a key to `false` to leave it unmapped. |
| `enabled` | `false` | Set to `true` to turn focus on at startup. |

```lua
require("pantry").setup({
  focus = {
    keys = { ["<M-i>"] = false },
  },
})
```

With `focus = {}`, the jar is set up and off. `:checkhealth pantry` reports it as set up and off
until you turn it on.

## Highlight

`PantryFocusDim` colors the dimmed lines. It links to `Comment`. A colorscheme can set its own color
for it.

The focus jar dims floating windows and buffers that have a `buftype`, such as help and terminal
buffers, never.
