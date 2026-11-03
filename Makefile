.PHONY: test format deps

export XDG_DATA_HOME = $(CURDIR)/deps/xdg
export XDG_CONFIG_HOME = $(CURDIR)/deps/xdg
export XDG_STATE_HOME = $(CURDIR)/deps/xdg

PARSERS = bash json lua markdown markdown_inline python rust swift toml yaml
DEPS = deps/mini.nvim deps/nvim-treesitter deps/nvim-treesitter-context deps/nvim-treesitter-textobjects

test: deps
	nvim --headless --noplugin -u scripts/minimal_init.lua -c "lua MiniTest.run()"

deps: $(DEPS) deps/parsers.ok

deps/mini.nvim:
	git clone --filter=blob:none https://github.com/echasnovski/mini.nvim $@

deps/nvim-treesitter:
	git clone --filter=blob:none https://github.com/nvim-treesitter/nvim-treesitter $@

deps/nvim-treesitter-context:
	git clone --filter=blob:none https://github.com/nvim-treesitter/nvim-treesitter-context $@

deps/nvim-treesitter-textobjects:
	git clone --filter=blob:none https://github.com/nvim-treesitter/nvim-treesitter-textobjects $@

deps/parsers.ok: deps/nvim-treesitter
	nvim --headless --noplugin -u scripts/minimal_init.lua \
		-c "lua require('nvim-treesitter').install({ $(foreach p,$(PARSERS),'$(p)',) }):wait(600000)" -c qa
	touch $@

format:
	stylua lua tests scripts
