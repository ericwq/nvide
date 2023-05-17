local overrides = require("custom.configs.overrides")

---@type NvPluginSpec[]
local plugins = {

	-- Override plugin definition options

	{
		"neovim/nvim-lspconfig",
		dependencies = {
			-- format & linting
			{
				"jose-elias-alvarez/null-ls.nvim",
				config = function()
					require "custom.configs.null-ls"
				end,
			},
		},
		config = function()
			require "plugins.configs.lspconfig"
			require "custom.configs.lspconfig"
		end, -- Override to setup mason-lspconfig
	},

	-- override plugin configs
	{
		"williamboman/mason.nvim",
		opts = overrides.mason,
	},

	{
		"nvim-treesitter/nvim-treesitter",
		opts = overrides.treesitter,
	},

	{
		"nvim-tree/nvim-tree.lua",
		opts = overrides.nvimtree,
	},

	-- Install a plugin
	{
		"ojroques/nvim-osc52",
		event = "BufEnter",
		config = function()
			require "custom.configs.osc52"
		end,
	},

	{
		"max397574/better-escape.nvim",
		event = "InsertEnter",
		config = function()
			require("better_escape").setup()
		end,
	},

	{ -- refer https://github.com/nvim-treesitter/nvim-treesitter-context
		"nvim-treesitter/nvim-treesitter-context",
		event = "BufEnter",
		dependencies = {
			{
				"nvim-treesitter/nvim-treesitter",
			},
		},
		opts = function()
			return require "custom.configs.treesitter-context"
		end,
		-- config = function(_, opts)
		-- 	require("nvim-treesitter-context").setup(opts)
		-- end,
	},

	{ -- refer to https://github.com/siduck/dotfiles/blob/master/nvchad/custom/plugins/init.lua
		"windwp/nvim-ts-autotag",
		ft = {
			"html",
			"javascriptreact",
		},
		dependencies = {
			{
				"nvim-treesitter/nvim-treesitter",
			},
		},
	},

	{
		"stevearc/aerial.nvim",
		event = "BufEnter",
		config = function()
			require('aerial').setup({
				close_on_select = true,
				-- optionally use on_attach to set keymaps when aerial has attached to a buffer
				on_attach = function(bufnr)
					-- Jump forwards/backwards with '{' and '}'
					vim.keymap.set('n', '{', '<cmd>AerialPrev<CR>', {
						buffer = bufnr,
					})
					vim.keymap.set('n', '}', '<cmd>AerialNext<CR>', {
						buffer = bufnr,
					})
				end,
			})
			-- You probably also want to set a keymap to toggle aerial
			vim.keymap.set('n', '<leader>a', '<cmd>AerialToggle<CR>')
		end,
	},

	{ -- https://github.com/simrat39/symbols-outline.nvim
		"simrat39/symbols-outline.nvim",
		event = "BufEnter",
		dependencies = {
			{
				"neovim/nvim-lspconfig",
			},
		},
		opts = {
			show_guides = false,
			auto_close = true,
			show_symbol_details = false,
		},
	},

	-- To make a plugin not be loaded
	-- {
	--   "NvChad/nvim-colorizer.lua",
	--   enabled = false
	-- },
}

return plugins
