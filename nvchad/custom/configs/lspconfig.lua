-- custom.plugins.lspconfig
local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require("lspconfig")

-- hint: all lang server names can be found here:
--       https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
-- or by: `:help lspconfig-all`
local servers = {
	"dockerls",
	"gopls",
	"clangd",
}

for _, lsp in ipairs(servers) do
	local opts = {
		on_attach = on_attach,
		capabilities = capabilities,
	}

	-- if lsp == "lua_ls" then
	-- 	opts.settings = {
	-- 		Lua = {
	-- 			diagnostics = {
	-- 				globals = {
	-- 					"vim",
	-- 				},
	-- 			},
	-- 		},
	-- 	}
	-- end

	lspconfig[lsp].setup(opts)
end

-- local on_attach = require("plugins.configs.lspconfig").on_attach
-- local attach = require("plugins.configs.lspconfig").on_attach
-- local capabilities = require("plugins.configs.lspconfig").capabilities
--
-- local lspconfig = require "lspconfig"
--
-- lspconfig.dockerls.setup {
-- 	on_attach = function(client, bufnr)
-- 		attach(client, bufnr)
-- 		client.server_capabilities.documentFormattingProvider = true
-- 		client.server_capabilities.documentRangeFormattingProvider = true
-- 	end,
-- 	-- on_attach = on_attach_vim,
-- 	capabilities = capabilities,
-- 	filetypes = {
-- 		"dockerfile",
-- 		"Dockerfile",
-- 	},
-- };

-- c/c++ language server
-- lspconfig.clangd.setup {
-- 	-- on_attach = attach,
-- 	on_attach = function(client, bufnr)
-- 		attach(client, bufnr)
-- 		client.server_capabilities.documentFormattingProvider = true
-- 		client.server_capabilities.documentRangeFormattingProvider = true
-- 	end,
-- 	capabilities = capabilities,
-- 	root_dir = lspconfig.util.root_pattern("compile_commands.json", "compile_flags.txt", ".git"),
-- 	flags = {
-- 		debounce_text_changes = 150,
-- 	},
-- 	cmd = {
-- 		"clangd",
-- 		"--background-index",
-- 		"--clang-tidy",
-- 	},
-- 	filetypes = {
-- 		"c",
-- 		"cpp",
-- 		"objc",
-- 		"objcpp",
-- 	},
-- }
-- go language server
-- cmd = {"gopls", "-remote", "auto", "-logfile", "/tmp/gopls.log"},
-- lspconfig.gopls.setup {
-- 	cmd = {
-- 		"gopls",
-- 		"serve",
-- 		-- "-rpc.trace",
-- 		-- "-logfile=auto",
-- 	},
-- 	flags = {
-- 		debounce_text_changes = 150,
-- 	},
-- 	on_attach = function(client, bufnr)
-- 		attach(client, bufnr)
-- 		client.server_capabilities.documentFormattingProvider = true
-- 		client.server_capabilities.documentRangeFormattingProvider = true
-- 	end,
-- 	-- on_attach = on_attach_vim,
-- 	capabilities = capabilities,
-- 	settings = {
-- 		gopls = {
-- 			-- https://github.com/golang/tools/blob/master/gopls/doc/settings.md#allowimplicitnetworkaccess-bool
-- 			-- allowImplicitNetworkAccess disables GOPROXY=off, allowing implicit module downloads rather
-- 			-- than requiring user action. This option will eventually be removed.
-- 			allowImplicitNetworkAccess = true,
-- 			-- experimentalWorkspaceModule = true,
-- 			-- analyses = {
-- 			-- 	unusedparams = true,
-- 			-- },
-- 			-- staticcheck = true,
-- 			linksInHover = false,
-- 			-- codelenses = {
-- 			-- 	generate = true,
-- 			-- 	gc_details = true,
-- 			-- 	regenerate_cgo = true,
-- 			-- 	tidy = true,
-- 			-- 	upgrade_depdendency = true,
-- 			-- 	vendor = true,
-- 			-- },
-- 			usePlaceholders = true,
-- 			gofumpt = true,
-- 		},
-- 	},
-- }
