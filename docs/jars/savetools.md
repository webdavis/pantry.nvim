# savetools

The savetools jar does the small jobs around a save that you would otherwise do by hand. It makes
a missing folder, makes a new script executable, and catches a slip such as `:w]`. It also adds a
save through sudo, a save that skips formatting, and a way to ask what a save would do.

## Turn it on

Add `savetools` to your setup. It needs Neovim 0.12 or newer.

```lua
require("pantry").setup({ savetools = {} })
```

## What a save does for you

Each tool tells you what it did in one line, with the reason. Set its option to `false` to turn
one off.

| Tool         | What it does                                                                        |
| ------------ | ----------------------------------------------------------------------------------- |
| `folders`    | Makes the folder when you save a file into one that does not exist                  |
| `executable` | Makes a new script executable, when its folder shows that scripts there are         |
| `typos`      | Saves your buffer when a slip such as `:w]` would have written a stray file instead |
| `vanished`   | Warns when the file was deleted on disk and your save brought it back               |
| `filetype`   | Sets the filetype after a save when the buffer had none                             |

### New scripts

The jar looks only at a save that creates a file, and only when the first line starts with `#!`.
It never changes a file that already exists. It decides in this order, and the first that applies
wins:

1. The folder is in `executable.never`: the file is left alone.
1. The folder is in `executable.always`, or is on your `PATH`: the file becomes executable.
1. Every other script in the folder is executable: the file becomes executable.
1. The folder has no other script: the file is left alone, and the jar says so.
1. Some scripts in the folder are executable and some are not: the file is left alone.

In `always` and `never`, a bare name such as `"bin"` matches any folder of that name. A path
matches that one folder, and `**` reaches the folders below it:

```lua
require("pantry").setup({
  savetools = {
    executable = {
      always = { "bin", "scripts", "~/dotfiles/**" },
      never = { "lib" },
    },
  },
})
```

### Slips

`:w]`, `:w\`, `:w;`, `:w'` and their like write a copy of your buffer under that one-key name and
leave your file unsaved. The jar removes the stray file and saves your buffer instead. It acts only
on a name of one or two of the keys beside Enter, and only when no file of that name exists.
`:w! ]` writes the name as you typed it.

## Save through sudo

`sudo()` saves a file that you cannot write yourself. It shows the real path, its owner and its
mode, and asks for your password on a hidden prompt. An empty answer cancels.

```lua
vim.keymap.set("n", "<leader>W", require("pantry.savetools").sudo)
```

- The password goes to sudo on its standard input. The jar does not keep it, and it does not reach
  your command history.
- The file keeps its owner and mode.
- When the file is a link, sudo writes the file it points to, and the prompt shows that path.
- `sudo()` refuses a file that changed on disk since Neovim read it.
- sudo gets 15 seconds. After that the jar gives up and tells you.

## Save without formatting

`plain()` saves the buffer once and marks the save as plain. While it writes,
`vim.b.pantry_save` is `"plain"`, and it is `"sudo"` during a sudo save. A formatter that reads it
can stand aside:

```lua
require("conform").setup({
  format_on_save = function(buf)
    if vim.b[buf].pantry_save == nil then
      return {}
    end
  end,
})
```

## Ask what a save would do

`explain()` shows what saving the current buffer would do, and saves nothing. It returns the same
lines as a list.

```text
It would make the folder /home/you/project/bin.
It would make deploy executable, because bin is in executable.always.
```

## Options

| Option       | Default                              | Meaning                                                    |
| ------------ | ------------------------------------ | ---------------------------------------------------------- |
| `notify`     | `true`                               | Set to `false` to silence the notes. Warnings still show   |
| `executable` | `{ always = { "bin" }, never = {} }` | Folders for new scripts. Set to `false` to turn the tool off |
| `folders`    | `true`                               | Set to `false` to turn the tool off                        |
| `typos`      | `true`                               | Set to `false` to turn the tool off                        |
| `vanished`   | `true`                               | Set to `false` to turn the tool off                        |
| `filetype`   | `true`                               | Set to `false` to turn the tool off                        |
| `enabled`    | `true`                               | Set to `false` to leave the jar out                        |

`enabled = false` leaves the jar out, as it does for every jar. pantry then does not set it up, and
`:checkhealth pantry` does not list it.

## Functions

Call these from a mapping or from the command line.

| Function    | What it does                                                   |
| ----------- | -------------------------------------------------------------- |
| `sudo()`    | Saves the current buffer through sudo.                         |
| `plain()`   | Saves the current buffer once, marked as a plain save.         |
| `explain()` | Shows what a save of the current buffer would do, and returns it. |
