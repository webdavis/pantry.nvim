# autosave

The autosave jar saves a file for you when you stop working on it. It never overwrites a file that
changed on disk, and it tells other plugins which kind of save it is making.

## Turn it on

Add `autosave` to your setup. It needs Neovim 0.12 or newer.

```lua
require("pantry").setup({ autosave = {} })
```

With `autosave = {}`, the jar saves from the start. To set it up and leave it off until you turn it
on, use `mode = "off"` and map `toggle()` to a key of your own:

```lua
require("pantry").setup({ autosave = { mode = "off" } })

vim.keymap.set("n", "<leader>uv", require("pantry.autosave").toggle)
```

## When it saves

The jar makes two kinds of save:

- A leave save happens at once when you leave the buffer, suspend Neovim, or quit.
- A pause save happens `delay` milliseconds after you change text or leave insert mode. Going back
  into insert mode holds it.

When Neovim loses focus, the jar saves every changed buffer, not only the one you are in. A program
that reads your files from disk, such as a coding agent in another pane, then sees your latest text.

While a macro records or runs, pause saves wait. Leave saves still happen.

## What it leaves alone

The jar saves only an ordinary file buffer that has changes. It skips these:

- A buffer with no name, and a buffer with a `buftype`, such as a help or terminal buffer.
- A file that is not on disk yet. Your first save by hand creates it.
- The filetypes in `skip`.
- A buffer that `condition` returns `false` for.
- A buffer where you set `vim.b.pantry_autosave = false`.

## When a save would do harm

The jar does not save in these cases. It tells you once for each buffer, and again only after the
buffer is saved or reloaded:

- The file changed on disk since Neovim read or wrote it. Saving would overwrite that change.
- The file is gone from disk. Saving would bring it back.
- You cannot write the file.

## The kind of save

While the jar writes a buffer, `vim.b.pantry_save` in that buffer is `"leave"` or `"pause"`. At
every other time it is `nil`, including during a save by hand.

A plugin that acts on every save can read it. This keeps conform.nvim from formatting on a pause
save, so the text does not move under the cursor while you work:

```lua
require("conform").setup({
  format_on_save = function(buf)
    if vim.b[buf].pantry_save ~= "pause" then
      return {}
    end
  end,
})
```

## Let rules decide

With `mode = "auto"`, the jar decides for each buffer. It checks these in order, and the first that
applies wins:

1. `when`, if it returns `true` or `false`.
1. The file's git repository is in the middle of a rebase, merge, cherry-pick, revert or bisect: no
   save.
1. The buffer has conflict markers: no save.
1. The file is under a path in `paths.off`: no save.
1. `paths.on` lists any path and the file is under none of them: no save.
1. Otherwise the jar saves.

This saves only inside a notes folder, and never inside a work project:

```lua
require("pantry").setup({
  autosave = {
    mode = "auto",
    paths = { on = { "~/notes/**" } },
    when = function(buf)
      if vim.api.nvim_buf_get_name(buf):find("/work/", 1, true) then
        return false
      end
    end,
  },
})
```

## Options

| Option      | Default                 | Meaning                                                                         |
| ----------- | ----------------------- | ------------------------------------------------------------------------------- |
| `mode`      | `"on"`                  | `"on"` saves, `"off"` waits for you to turn it on, `"auto"` lets rules decide   |
| `delay`     | `1000`                  | Milliseconds to wait before a pause save                                        |
| `skip`      | `{}`                    | Filetypes to leave alone                                                        |
| `condition` | none                    | A function that gets the buffer number. Return `false` to leave the buffer alone |
| `paths`     | `{ on = {}, off = {} }` | Glob patterns for `"auto"`, such as `"~/notes/**"`                              |
| `when`      | none                    | A function for `"auto"` that gets the buffer number and returns `true` or `false` |
| `enabled`   | `true`                  | Set to `false` to leave the jar out                                             |

`enabled = false` leaves the jar out, as it does for every jar. pantry then does not set it up, and
`:checkhealth pantry` does not list it.

## Functions

Call these from a mapping or from the command line.

| Function    | What it does                                                    |
| ----------- | --------------------------------------------------------------- |
| `enable()`  | Turns saving on, in the mode from your setup.                   |
| `disable()` | Turns saving off and drops any pause save that is waiting.      |
| `toggle()`  | Turns saving on when it is off, and off when it is on.          |
| `status()`  | Says what the jar would do with the current buffer, and why.    |

`status()` returns a table. `saves` is whether the mode and its rules allow a save, `reason` is the
rule that decided, and `pending` is whether a pause save is waiting:

```lua
{ mode = "auto", saves = false, reason = "a git rebase is in progress", pending = false }
```

Show it in a statusline:

```lua
local status = require("pantry.autosave").status()
local text = status.saves and "autosave" or ("autosave held: " .. status.reason)
```
