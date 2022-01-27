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

M.nvimtree = {
	filters = {
		dotfiles = true,
	},
	auto_close = true,
}

return M