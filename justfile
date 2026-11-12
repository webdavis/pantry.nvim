set shell := ["bash", "-euo", "pipefail", "-c"]

export XDG_DATA_HOME := justfile_directory() / "deps/xdg"
export XDG_CONFIG_HOME := justfile_directory() / "deps/xdg"
export XDG_STATE_HOME := justfile_directory() / "deps/xdg"

parsers := "bash json lua markdown markdown_inline python rust swift toml yaml"
pins := "echasnovski/mini.nvim@f9ac12d7cbd2563cfc2cce9a8152fc8df2ad0d6f nvim-treesitter/nvim-treesitter@19bdfc04f40ed2ccb3340591d125f759b0406875 nvim-treesitter/nvim-treesitter-context@8decd73460d26ef0a0befb745d022dd1fc2c38b8 nvim-treesitter/nvim-treesitter-textobjects@5c7b0263797dfd1bd6202f2b219f3b53a80b2187"
latest := env("LATEST_DEPS", "")

test: deps
    nvim --headless --noplugin -u scripts/minimal_init.lua -c "lua MiniTest.run()"

deps:
    #!/usr/bin/env bash
    set -euo pipefail
    unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE
    for pin in {{ pins }}; do
      repo="${pin%@*}"
      rev="${pin#*@}"
      dir="deps/${repo#*/}"
      [ -d "$dir" ] || git clone --quiet --filter=blob:none "https://github.com/$repo" "$dir"
      if [ -n "{{ latest }}" ]; then
        git -C "$dir" fetch --quiet origin
        rev=origin/HEAD
      fi
      git -C "$dir" checkout --quiet --detach "$rev" 2>/dev/null || {
        git -C "$dir" fetch --quiet origin
        git -C "$dir" checkout --quiet --detach "$rev"
      }
    done
    built="$(git -C deps/nvim-treesitter rev-parse HEAD)"
    if [ "$(cat deps/parsers.ok 2>/dev/null)" != "$built" ]; then
      nvim --headless --noplugin -u scripts/minimal_init.lua \
        -c "lua local ts, langs = require('nvim-treesitter'), vim.split('{{ parsers }}', ' '); ts.install(langs):wait(600000); ts.update(langs):wait(600000)" \
        -c qa
      echo "$built" > deps/parsers.ok
    fi

format:
    stylua lua tests scripts
