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
	},
}

M.nvimtree = {
	filters = {
		dotfiles = true,
	},
	auto_close = true,
}

return M
