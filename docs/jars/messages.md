# messages

The messages jar shows every message in Neovim's ui2 message window. It adds a key that lists every
message since startup, each with the time it arrived, its level and its kind.

## Turn it on

Add `messages` to your setup. It needs Neovim 0.12 or newer.

```lua
require("pantry").setup({ messages = {} })
```

## What it needs

The history opens in a [snacks.nvim](https://github.com/folke/snacks.nvim) picker when snacks.nvim
is installed. Without it, the history opens in a plain buffer.

## Keys

The key works in normal mode.

| Key          | Action                                  |
| ------------ | --------------------------------------- |
| `<leader>nh` | Show the message history, newest first. |

## How it turns on ui2

At setup, the messages jar turns on ui2 with this call:

```lua
require("vim._core.ui2").enable({ msg = { target = "msg" } })
```

ui2 then shows every message, notifications included, in Neovim's message window.

ui2 is private Neovim API. A Neovim release can change it or remove it without notice. The jar
handles that this way:

- When Neovim has no ui2, the jar leaves it alone. The key still works, and the history lists the
  lines of `:messages` with no time and no kind.
- When ui2 has no message handler to read, the jar records nothing and every message still shows.
  The history lists the lines of `:messages`, with no time and no kind.
- When a new handler takes different arguments, the jar skips the history row for each message. The
  message still shows.

## Messages from before setup

The jar cannot record a message that appeared before setup. The history lists those messages below
the recorded ones, as the lines of `:messages` with no time and no kind.

## Levels

Each message in the history has one of three levels:

- `error` for errors.
- `warn` for warnings.
- `info` for every other message.

A message drawn in the `WarningMsg` or `ErrorMsg` highlight counts as a warning or an error. For
example, a `vim.notify` warning has the level `warn`.

## Views

The history opens in one of two views.

The snacks view opens a snacks.nvim picker:

- Every row uses the layout of the snacks notifications picker.
- A row with no time has a blank time column.
- A preview shows the whole message.

The buffer view opens a read-only buffer in a split:

- Each line shows the time, the level, the kind and the message.
- A message with no time shows `--:--:--` in place of the time.
- A message of several lines continues on indented lines.
- Press `q` to close the buffer.

## Options

These options set ui2, the view and the keys.

| Option | Default                          | Meaning                                                       |
| ------ | -------------------------------- | ------------------------------------------------------------- |
| `ui2`  | `true`                           | `false` leaves ui2 alone. A table goes to ui2 as its options. |
| `view` | `"auto"`                         | `"snacks"`, `"buffer"` or `"auto"`.                           |
| `keys` | `{ ["<leader>nh"] = "history" }` | Maps a key to an action, or to `false` to unmap it.           |

With `ui2 = false`, the jar records nothing, and the history lists the lines of `:messages`.

With `view = "auto"`, the history opens in the snacks view when snacks.nvim loads, and in the buffer
view otherwise.

The actions are:

- `"history"` shows the history in the view that `view` names.
- `"history_buffer"` shows the history in the buffer view.
- `"history_snacks"` shows the history in the snacks view.

Any other action name stops setup with an error that names the key and the valid actions.

This makes the buffer view the default, turns off `<leader>nh`, and maps `<leader>sm` to the snacks
view:

```lua
require("pantry").setup({
  messages = {
    view = "buffer",
    keys = { ["<leader>nh"] = false, ["<leader>sm"] = "history_snacks" },
  },
})
```
