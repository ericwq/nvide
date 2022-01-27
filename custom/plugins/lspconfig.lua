local M = {}

M.setup_lsp = function(attach, capabilities)

	-----------------------------------------------------------
	-- Neovim LSP configuration file
	-----------------------------------------------------------
	-- Plugin: nvim-lspconfig
	-- for language server setup see: https://github.com/neovim/nvim-lspconfig
	-- https://github.com/ChrisAmelia/dotfiles/blob/master/nvim/lua/lsp.lua#L108-L120
	--

	local lspconfig = require "lspconfig"

	-- c/c++ language server
	lspconfig.clangd.setup {
		on_attach = attach,
		capabilities = capabilities,
		root_dir = lspconfig.util.root_pattern("compile_commands.json", "compile_flags.txt", ".git"),
		flags = {
			debounce_text_changes = 150,
		},
		cmd = {
			"clangd",
			"--background-index",
			"--clang-tidy",
		},
		filetypes = {
			"c",
			"cpp",
			"objc",
			"objcpp",
		},
	}

	-- go language server
	-- cmd = {"gopls", "-remote", "auto", "-logfile", "/tmp/gopls.log"},
	lspconfig.gopls.setup {
		cmd = {
			"gopls",
			"serve",
			"-rpc.trace",
			"-logfile=auto",
		},
		flags = {
			debounce_text_changes = 150,
		},
		on_attach = attach,
		-- on_attach = on_attach_vim,
		capabilities = capabilities,
		settings = {
			gopls = {
				-- https://github.com/golang/tools/blob/master/gopls/doc/settings.md#allowimplicitnetworkaccess-bool
				-- allowImplicitNetworkAccess disables GOPROXY=off, allowing implicit module downloads rather
				-- than requiring user action. This option will eventually be removed.
				allowImplicitNetworkAccess = true,
				-- experimentalWorkspaceModule = true,
				analyses = {
					unusedparams = true,
				},
				staticcheck = true,
				linksInHover = false,
				codelenses = {
					generate = true,
					gc_details = true,
					regenerate_cgo = true,
					tidy = true,
					upgrade_depdendency = true,
					vendor = true,
				},
				usePlaceholders = true,
				gofumpt = true,
			},
		},
	}

	-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#sumneko_lua
	local runtime_path = vim.split(package.path, ';')
	table.insert(runtime_path, "lua/?.lua")
	table.insert(runtime_path, "lua/?/init.lua")

	lspconfig.sumneko_lua.setup {
		on_attach = attach,
		capabilities = capabilities,
		flags = {
			debounce_text_changes = 150,
		},
		root_dir = lspconfig.util.root_pattern('.git'),
		-- function(client, bufnr)
		--     client.resolved_capabilities.document_formatting = false
		--     vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>fm", "<cmd>lua vim.lsp.buf.formatting()<CR>", {})
		-- end,
		settings = {
			Lua = {
				runtime = {
					-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
					version = 'LuaJIT',
					-- Setup your lua path
					path = runtime_path,
				},
				diagnostics = {
					-- Get the language server to recognize the `vim` global
					globals = {
						'vim',
						'use',
					},
				},
				workspace = {
					-- Make the server aware of Neovim runtime files
					-- library = vim.api.nvim_get_runtime_file("", true),
					-- refer to https://github.com/ChrisAmelia/dotfiles/blob/master/nvim/lua/lsp.lua#L108-L120
					library = {
						[vim.fn.expand('$VIMRUNTIME/lua')] = true,
						[vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
					},
					maxPreload = 100000,
					preloadFileSize = 10000,
				},
				-- Do not send telemetry data containing a randomized but unique identifier
				telemetry = {
					enable = false,
				},
			},
		},
	}

end

return M
