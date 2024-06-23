-- every spec file under the "plugins" directory will be loaded automatically by lazy.nvim
--
-- In your plugin files, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim plugins
return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		opts = {
			transparent_background = true,
			flavour = "frappe",
		},
		priority = 1000,
		lazy = false,
	},
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "catppuccin",
		},
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = {
			"nvim-lua/lsp-status.nvim",
		},
		opts = {
			sections = {
				lualine_z = {
					function()
						return require("lsp-status").status()
					end,
				},
			},
		},
	},
}
