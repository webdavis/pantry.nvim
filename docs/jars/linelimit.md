# linelimit

The linelimit jar marks lines that come close to a line length limit or go past it.

## Turn it on

Add `linelimit` to your setup:

```lua
require("pantry").setup({ linelimit = {} })
```

## What it draws

The jar draws on each line by its length:

- A line within `near` columns of the limit gets a faint `│` in the column just after the limit.
- A shorter line gets nothing.
- A line past the limit gets `+N` after its end. N is how many columns the line is over.
- Text past the limit keeps its normal color.

The jar measures a line the way it looks on screen:

- It checks only the lines on the screen.
- It counts width in screen columns, so a tab or a wide character counts as wide as it looks.
- Concealed text still counts.

## Where the limit comes from

The jar uses the first of these that is set for the window:

1. The window's `colorcolumn`. The jar reads the first entry. `81` gives a limit of 80, and `+1`
   gives a limit equal to `textwidth`.
1. `textwidth`, when it is above 0.
1. `max_line_length` from an EditorConfig file.
1. The `filetypes` option.

If none of these is set, the window shows nothing.

While the jar is on, it hides Neovim's own `colorcolumn` stripe in the windows it checks. It still
reads the `colorcolumn` value as the limit.

## Windows it leaves alone

The jar skips these windows:

- Floating windows.
- Buffers with a `buftype`, such as help or terminal buffers.
- The filetypes in `skip`.

## Colors

The jar draws with two highlight groups. A colorscheme can set its own colors for both.

| Group                 | Draws          | Links to                    |
| --------------------- | -------------- | --------------------------- |
| `PantryLineLimit`     | The `│` mark   | `NonText`                   |
| `PantryLineLimitOver` | The `+N` count | `DiagnosticVirtualTextWarn` |

## Options

These options set the limit and where the jar draws.

| Option      | Default                                         | Meaning                                                         |
| ----------- | ----------------------------------------------- | --------------------------------------------------------------- |
| `near`      | `10`                                            | How many columns before the limit a line starts to get the mark |
| `filetypes` | `{}`                                            | A limit for each filetype, such as `{ lua = 120 }`              |
| `skip`      | `{ "help", "qf", "man", "terminal", "prompt" }` | Filetypes to leave alone                                        |
| `enabled`   | `true`                                          | Set to `false` to keep the jar off                              |

A `skip` list that you pass replaces the default list. This sets the mark 5 columns before the
limit, and a limit for Lua and markdown:

```lua
require("pantry").setup({
  linelimit = {
    near = 5,
    filetypes = { lua = 120, markdown = 80 },
  },
})
```

## Functions

These functions turn the jar off and on while Neovim runs.

Turn the jar off and put the `colorcolumn` stripe back:

```lua
require("pantry.linelimit").disable()
```

Turn the jar back on:

```lua
require("pantry.linelimit").enable()
```
