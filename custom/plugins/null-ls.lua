local null_ls = require "null-ls"
local b = null_ls.builtins

local sources = {
	-- If you have performance issues with a diagnostic source, you can
	-- configure it to run on save (not on each change) by overriding method:
	-- method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
	--
	-- should echo 1 if available (and 0 if not)
	-- :echo executable("eslint")

	-- others
	b.formatting.prettierd.with({
		filetypes = {
			"html",
			"markdown",
			"yaml",
			"json",
		},
	}),

	-- go
	-- b.formatting.goimports,
	-- b.formatting.gofmt,
	-- b.diagnostics.golangci_lint.with({filetypes = {"go"}, diagnostics_format = "(#{s}) #{m}"}),

	-- english text
	b.diagnostics.proselint.with({
		diagnostics_format = "(#{s}) #{m}",
	}),

	-- lua
	b.formatting.lua_format.with({
		extra_args = {
			"--use-tab",
			"--indent-width=1",
			"--column-limit=150",
			"--no-keep-simple-control-block-one-line",
			"--no-keep-simple-function-one-line",
			"--chop-down-table",
			"--chop-down-kv-table",
			"--chop-down-parameter",
			"--break-after-table-lb",
			"--break-after-functiondef-lp",
			"--column-table-limit=20",
			"--extra-sep-at-table-end",
		},
	}),

	-- TOOD not sure how to use it ?
	-- b.completion.spell,

	-- c/c++
	b.formatting.clang_format,
	b.diagnostics.cppcheck.with({
		diagnostics_format = "(#{s}) #{m}",
	}),

	--[[
--
   -- Lua
   b.formatting.stylua,
   b.diagnostics.luacheck.with { extra_args = { "--global vim" } },

   -- Shell
   b.formatting.shfmt,
   b.diagnostics.shellcheck.with { diagnostics_format = "#{m} [#{c}]" },
--]]
}

require("null-ls").setup({
	debug = true,
	sources = sources,
	log = {
		enable = true,
		level = "info",
		use_console = false,
	},
	-- diagnostics_format = "(#{s}) #{m}",

	-- format on save
	on_attach = function(client)
		if client.resolved_capabilities.document_formatting then
			vim.cmd "autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()"
		end
	end,
})

