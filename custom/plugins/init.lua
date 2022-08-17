return {
	-- replace the alpha-nvim
	["goolord/alpha-nvim"] = {
		disable = false,
		config = function()
			require "custom.plugins.alpha"
		end,
	},

	-- treesitter context
	['romgrk/nvim-treesitter-context'] = {
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
			require("custom.plugins.null-ls").setup()
		end,
	},

	-- symbols-outline
	-- https://github.com/simrat39/symbols-outline.nvim
	['simrat39/symbols-outline.nvim'] = {
		after = "nvim-lspconfig",
		setup = function()
			vim.g.symbols_outline = {
				relative_width = true,
				show_guides = false,
				width = 20,
				auto_close = true,
				auto_preview = false,
				show_symbol_details = false,
			}
		end,
		config = function()
			require("symbols-outline").setup()
		end,
	},

	-- use {
	-- 	"nvim-telescope/telescope-media-files.nvim",
	-- 	after = "telescope.nvim",
	-- 	config = function()
	-- 		require("telescope").setup {
	-- 			extensions = {
	-- 				media_files = {
	-- 					filetypes = {
	-- 						"png",
	-- 						"webp",
	-- 						"jpg",
	-- 						"jpeg",
	-- 					},
	-- 					find_cmd = "rg", -- find command (defaults to `fd`)
	-- 				},
	-- 			},
	-- 		}
	--
	-- 		require("telescope").load_extension "media_files"
	-- 	end,
	-- }
}
