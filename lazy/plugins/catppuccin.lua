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
			styles = {
				comments = {
					"italic",
				},
			},
			-- color_overrides = {
			--   all = {
			--     overlay0 = "#C0C0C0",
			--   },
			-- },
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
}
