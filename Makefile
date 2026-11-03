.PHONY: test format

test: deps/mini.nvim
	nvim --headless --noplugin -u scripts/minimal_init.lua -c "lua MiniTest.run()"

deps/mini.nvim:
	git clone --filter=blob:none https://github.com/echasnovski/mini.nvim $@

format:
	stylua lua tests scripts
