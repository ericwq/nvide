return {
	-- { import = "lazyvim.plugins.extras.lang.markdown", },
	{ import = "lazyvim.plugins.extras.lang.java" },
	{ import = "lazyvim.plugins.extras.lang.docker" },
	{ import = "lazyvim.plugins.extras.lang.go" },
	{ import = "lazyvim.plugins.extras.lang.rust" },
	{ import = "lazyvim.plugins.extras.lang.toml" },
	{ import = "lazyvim.plugins.extras.lang.clangd" },
	{ import = "lazyvim.plugins.extras.editor.mini-files" },
	{ import = "lazyvim.plugins.extras.editor.aerial" },
	-- { import = "lazyvim.plugins.extras.editor.outline" },
	-- { import = "lazyvim.plugins.extras.coding.mini-comment" },
	-- { import = "lazyvim.plugins.extras.coding.luasnip" },
	{ import = "lazyvim.plugins.extras.ui.treesitter-context" },
	{ import = "lazyvim.plugins.extras.test.core" },
	{ import = "lazyvim.plugins.extras.dap.core" },
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				clangd = { mason = false },
				gopls = { mason = false },
				-- codelldb = { mason = false },
			},
		},
	},
	{
		"nvim-neo-tree/neo-tree.nvim",
		opts = {
			close_if_last_window = true,
		},
	},
	{
		"stevearc/aerial.nvim",
		opts = {
			layout = {
				max_width = { 50, 0.3 },
			},
			close_on_select = true,
		},
	},
	-- {
	--   "hedyhli/outline.nvim",
	--   opts = {
	--     outline_window = { auto_close = true },
	--   },
	-- },
	-- {
	--   "L3MON4D3/LuaSnip",
	--   lazy = true,
	-- },
}
