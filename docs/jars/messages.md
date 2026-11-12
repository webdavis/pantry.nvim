# messages

The messages jar turns on Neovim's ui2 message window and adds a key that lists every message
since startup. Each message in the list shows the time it arrived, its level and its kind.

The messages jar is off until you turn it on. It needs Neovim 0.12 or newer.

```lua
require("pantry").setup({ messages = {} })
```

## ui2

At setup, the messages jar runs `require("vim._core.ui2").enable({ msg = { target = "msg" } })`.
ui2 then shows every message, notifications included, in Neovim's message window.

ui2 is private Neovim API. A Neovim release can change it or remove it without notice. The jar
reads each message from ui2's `msg_show` handler to record its time, level and kind. When that
handler is missing, the jar records nothing and every message still shows. The history then lists
the lines of `:messages`, with no time and no kind. When a new handler takes different arguments,
the jar skips the history row for each message and the message still shows.

The jar cannot record a message that appeared before setup. The history lists those messages
below the recorded ones, as the lines of `:messages` with no time and no kind.

## Keys

| Key | Action |
| --- | --- |
| `<leader>nh` | Show the message history, newest first. |

## Views

The history opens in one of two views:

- The snacks view opens a [snacks.nvim](https://github.com/folke/snacks.nvim) picker laid out like
  the snacks notifications picker. A preview shows the whole message.
- The buffer view opens a read-only buffer in a split. Each line shows the time, the level, the
  kind and the message. A message of several lines continues on indented lines. Press `q` to close
  the buffer.

The level is `error` for errors, `warn` for warnings and `info` for every other message.

## Options

| Option | Default | Meaning |
| --- | --- | --- |
| `ui2` | `true` | `false` leaves ui2 alone. A table goes to ui2 as its options. |
| `view` | `"auto"` | `"snacks"`, `"buffer"` or `"auto"`. |
| `keys` | `{ ["<leader>nh"] = "history" }` | Maps a key to an action, or to `false` to unmap it. |

With `view = "auto"`, the history opens in the snacks view when snacks.nvim loads and in the buffer
view otherwise.

The actions are:

- `"history"` shows the history in the view that `view` names.
- `"history_buffer"` shows the history in the buffer view.
- `"history_snacks"` shows the history in the snacks view.

```lua
require("pantry").setup({
  messages = {
    view = "buffer",
    keys = { ["<leader>nh"] = false, ["<leader>sm"] = "history_snacks" },
  },
})
```
