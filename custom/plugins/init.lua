return {
	-- replace the alpha-nvim
	["goolord/alpha-nvim"] = {
		disable = false,
		config = function()
			require "custom.plugins.alpha"
		end,
	},

	-- treesitter context
	["romgrk/nvim-treesitter-context"] = {
		after = "nvim-treesitter",
		config = function()
			require("custom.plugins.treesitter-context").setup()
		end,
	},

	-- refer to https://github.com/siduck/dotfiles/blob/master/nvchad/custom/plugins/init.lua
	["windwp/nvim-ts-autotag"] = {
		ft = {
			"html",
			"javascriptreact",
		},
		after = "nvim-treesitter",
		config = function()
			require("nvim-ts-autotag").setup()
		end,
	},

	["neovim/nvim-lspconfig"] = {
		opt = true,
		setup = function()
			require("core.lazy_load").on_file_open "nvim-lspconfig"
		end,
		config = function()
			require "plugins.configs.lspconfig"
			require "custom.plugins.lspconfig"
		end,
	},

	["jose-elias-alvarez/null-ls.nvim"] = {
		after = "nvim-lspconfig",
		config = function()
			require"custom.plugins.null-ls".setup()
		end,
	},

	-- symbols-outline
	-- https://github.com/simrat39/symbols-outline.nvim
	["simrat39/symbols-outline.nvim"] = {
		after = "nvim-lspconfig",
		setup = function()
			require("core.lazy_load").on_file_open "symbols-outline.nvim"
		end,
		config = function()
			local opts = {
				show_guides = false,
				auto_close = true,
				show_symbol_details = false,
			}
			require("symbols-outline").setup(opts)
		end,
	},
}
