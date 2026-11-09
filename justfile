set shell := ["bash", "-euo", "pipefail", "-c"]

export XDG_DATA_HOME := justfile_directory() / "deps/xdg"
export XDG_CONFIG_HOME := justfile_directory() / "deps/xdg"
export XDG_STATE_HOME := justfile_directory() / "deps/xdg"

parsers := "bash json lua markdown markdown_inline python rust swift toml yaml"
plugins := "echasnovski/mini.nvim nvim-treesitter/nvim-treesitter nvim-treesitter/nvim-treesitter-context nvim-treesitter/nvim-treesitter-textobjects"

test: deps
    nvim --headless --noplugin -u scripts/minimal_init.lua -c "lua MiniTest.run()"

deps:
    for plugin in {{ plugins }}; do \
      [ -d "deps/${plugin#*/}" ] || git clone --filter=blob:none "https://github.com/$plugin" "deps/${plugin#*/}"; \
    done
    [ -f deps/parsers.ok ] || { \
      nvim --headless --noplugin -u scripts/minimal_init.lua \
        -c "lua require('nvim-treesitter').install(vim.split('{{ parsers }}', ' ')):wait(600000)" -c qa \
      && touch deps/parsers.ok; }

format:
    stylua lua tests scripts
