local M = {}

M.treesitter = {
	ensure_installed = {
		"lua",
		"go",
		"c",
		"cpp",
		"yaml",
		"json",
		"markdown",
		"dockerfile",
		"proto",
		-- "html",
		-- "css",
		-- "javascript",
	},
	highlight = {
		enable = true,
		use_languagetree = true,
		additional_vim_regex_highlighting = false,
	},

	-- enable Indentation
	indent = {
		enable = true,
	},

	-- enable Incremental selection
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "gnn",
			node_incremental = "grn",
			scope_incremental = "grc",
			node_decremental = "grm",
		},
	},
}

M.mason = {
	ensure_installed = {
		-- lua stuff
		-- "lua-language-server",
		-- "stylua",

		-- web dev stuff
		-- "css-lsp",
		-- "html-lsp",
		-- "typescript-language-server",
		-- "deno",
		"proselint",
		"prettierd",
		"prettier",
		"dockerfile-language-server",
	},
}

-- git support in nvimtree
M.nvimtree = {
	git = {
		enable = true,
	},

	renderer = {
		highlight_git = true,
		icons = {
			show = {
				git = true,
			},
		},
	},
	filters = {
		dotfiles = true,
	},
	view = {
		hide_root_folder = false,
	},
	actions = {
		open_file = {
			quit_on_open = true,
		},
	},
}

M.blankline = {
	show_current_context = false,
	show_current_context_start = false,
}
return M
