# linelimit

`pantry.linelimit` marks lines that come close to a line length limit or go past it.

```lua
require("pantry").setup({ linelimit = {} })
```

## What it draws

- A line within `near` columns of the limit gets a faint `│` in the column just after the limit.
  Shorter lines get nothing.
- A line past the limit gets `+N` after its end. N is how many columns the line is over.
- Text past the limit keeps its normal color.

The jar checks only the lines on the screen. It counts width in screen columns, so a tab or a
wide character counts as wide as it looks. Concealed text still counts.

## Where the limit comes from

The jar uses the first of these that is set for the window:

1. The window's `colorcolumn`. The jar reads the first entry. `81` gives a limit of 80, and `+1`
   gives a limit equal to `textwidth`.
2. `textwidth`, when it is above 0.
3. `max_line_length` from an EditorConfig file.
4. The `filetypes` option.

If none of these is set, the window shows nothing.

While the jar is on, it hides Neovim's own `colorcolumn` stripe in the windows it checks. It still
reads the `colorcolumn` value as the limit.

## What it skips

The jar skips floating windows, buffers with a `buftype` such as help or terminal buffers, and
the filetypes in `skip`.

## Highlights

| Group | Draws | Links to |
|---|---|---|
| `PantryLineLimit` | The `│` mark | `NonText` |
| `PantryLineLimitOver` | The `+N` count | `DiagnosticVirtualTextWarn` |

A colorscheme can set its own colors for both groups.

## Options

| Option | Default | Meaning |
|---|---|---|
| `near` | `10` | How many columns before the limit a line starts to get the mark |
| `filetypes` | `{}` | A limit for each filetype, such as `{ lua = 120 }` |
| `skip` | `{ "help", "qf", "man", "terminal", "prompt" }` | Filetypes to leave alone |
| `enabled` | `true` | Set to `false` to keep the jar off |

A `skip` list that you pass replaces the default list.

```lua
require("pantry").setup({
  linelimit = {
    near = 5,
    filetypes = { lua = 120, markdown = 80 },
  },
})
```

## Turn it on and off

`require("pantry.linelimit").disable()` turns the jar off and puts the `colorcolumn` stripe back.
`enable()` turns it back on.
