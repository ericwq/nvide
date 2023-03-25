local present, null_ls = pcall(require, "null-ls")

if not present then
	return
end

local b = null_ls.builtins

local sources = {

	-- webdev stuff
	-- b.formatting.deno_fmt, -- choosed deno for ts/js files cuz its very fast!
	-- b.formatting.prettier.with {
	-- 	filetypes = {
	-- 		"html",
	-- 		"markdown",
	-- 		"css",
	-- 		"json",
	-- 	},
	-- }, -- so prettier works only on these filetypes

	-- english text
	b.diagnostics.proselint.with({
		diagnostics_format = "(#{s}) #{m}",
	}),

	-- Lua
	-- b.formatting.stylua,
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

	-- cpp
	b.formatting.clang_format,

	-- go
	-- b.formatting.goimports,
	-- b.formatting.gofmt,
	-- b.diagnostics.golangci_lint.with({filetypes = {"go"}, diagnostics_format = "(#{s}) #{m}"}),
}

null_ls.setup {
	debug = true,
	sources = sources,

	log = {
		enable = true,
		level = "info",
		use_console = false,
	},

	-- format on save
	on_attach = function(client)
		if client.server_capabilities.documentFormattingProvider then
			vim.cmd "autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()"
		end
	end,
}
