# rsi

The rsi jar gives insert mode and the command line the readline editing keys that shells such as
bash use.

## Turn it on

Add `rsi` to your setup:

```lua
require("pantry").setup({ rsi = {} })
```

## Keys

The table shows what each key does in insert mode and on the command line.

| Key                 | Insert mode                                | Command line                                          |
| ------------------- | ------------------------------------------ | ----------------------------------------------------- |
| `<C-a>`             | Go to the first non-blank character        | Go to the start                                       |
| `<C-e>`             | Go to the end of the line                  | Neovim's own                                          |
| `<C-b>`             | Go left one character                      | Go left one character                                 |
| `<C-f>`             | Go right one character                     | Go right one character                                |
| `<C-d>`             | Delete the character under the cursor      | Delete the character under the cursor                 |
| `<C-k>`             | Kill to the end of the line                | Kill to the end                                       |
| `<C-u>`             | Kill back to the first non-blank character | Kill to the start                                     |
| `<C-w>`             | Kill back to the previous space            | Kill back to the previous space                       |
| `<M-p>`             | Kill back to the previous `/` or space     | Kill back to the previous `/` or space                |
| `<C-t>`             | Neovim's own                               | Swap the two characters around the cursor             |
| `<C-y>`             | Neovim's own                               | Paste the latest kill                                 |
| `<M-y>`             | Neovim's own                               | After `<C-y>`, swap the paste for the next older kill |
| `<M-b>`             | Go back one word                           | Go back one word                                      |
| `<M-f>`             | Go forward one word                        | Go forward one word                                   |
| `<M-d>`             | Kill the next word                         | Kill the next word                                    |
| `<M-BS>`, `<M-C-h>` | Kill the previous word                     | Kill the previous word                                |
| `<M-u>`             | Uppercase the next word                    | Uppercase the next word                               |
| `<M-l>`             | Lowercase the next word                    | Lowercase the next word                               |
| `<M-c>`             | Capitalize the next word                   | Capitalize the next word                              |
| `<M-.>`             | Neovim's own                               | Insert the last argument of the previous command      |

## Where a key keeps Neovim's meaning

Some keys fall back to Neovim's own meaning in a few places:

- At the end of a line, `<C-d>` removes one indent level in insert mode. On the command line it
  lists completions.
- At the end of a line, `<C-f>` keeps its insert-mode meaning. On the command line it opens the
  command-line window.
- At the end of a line, insert-mode `<C-e>` inserts the character below the cursor.
- When the cursor is already at the first non-blank character, insert-mode `<C-u>` kills to the
  start of the line.
- On a search line (`/` or `?`), `<C-t>` keeps Neovim's meaning.

## Paste what you killed

A kill deletes text and saves it in a list called the kill ring.

- Insert mode and the command line share one ring. Text you kill in a buffer can be pasted on the
  command line.
- `<C-y>` pastes the latest kill on the command line.
- Press `<M-y>` right after `<C-y>` to swap the paste for the next older kill.
- Kills leave every register as it was.

## Reuse the last argument

`<M-.>` inserts the last argument of the previous command on the command line. Press `<M-.>` again
to swap it for the last argument of the command before that.

## Use the keys with a completion menu

While a completion menu is open, `<C-e>`, `<C-k>` and `<C-y>` go to the menu.

- When [blink.cmp](https://github.com/Saghen/blink.cmp) is loaded, pantry checks its menu.
- Otherwise pantry checks Neovim's built-in popup menu.

## Repeat and undo

Insert-mode keys keep you in insert mode. `.` repeats the whole insert, moves and kills included,
and one `u` undoes it.

## Options

The rsi jar has one option.

| Option | Default | Meaning          |
| ------ | ------- | ---------------- |
| `keys` | `{}`    | Keys to turn off |

A key set to `false` keeps Neovim's own meaning in both modes. This turns off `<C-k>`:

```lua
require("pantry").setup({
  rsi = {
    keys = { ["<C-k>"] = false },
  },
})
```
