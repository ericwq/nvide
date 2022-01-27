local customPlugins = require "core.customPlugins"

customPlugins.add(function(use)
	-- A fast and lua alternative to filetype.vim
	-- https://github.com/nathom/filetype.nvim
	-- use ':echo &filetype' to detect the corrrect file type
	-- use `:set filetype=langname` to set file type.
	use "nathom/filetype.nvim"

	-- treesitter context
	use {
		'romgrk/nvim-treesitter-context',
		after = "nvim-treesitter",
		config = function()
			require("custom.plugins.treesitter-context").setup()
		end,
	}

	-- which-key
	-- https://github.com/folke/which-key.nvim
	use {
		"folke/which-key.nvim",
		event = "VimEnter",
		config = function()
			require("which-key").setup {
				-- your configuration comes here
				-- or leave it empty to use the default settings
				-- refer to the configuration section below
			}
		end,
	}

	-- symbols-outline
	-- https://github.com/simrat39/symbols-outline.nvim
	use {
		'simrat39/symbols-outline.nvim',
		after = "nvim-lspconfig",
		setup = function()
			vim.g.symbols_outline = {
				relative_width = true,
				show_guides = false,
				width = 50,
				auto_close = true,
				auto_preview = false,
			}
		end,
	}

	-- tagviewer
	-- use {
	-- 	'liuchengxu/vista.vim',
	-- 	disable = true,
	-- 	event = "BufRead",
	-- 	-- run before this plugin is loaded.
	-- 	-- setup =
	-- 	-- run after this plugin is loaded.
	-- 	config = function()
	-- 		require("custom.plugins.vista")
	-- 	end,
	-- }

	-- refer to https://github.com/siduck/dotfiles/blob/master/nvchad/custom/plugins/init.lua
	use {
		"windwp/nvim-ts-autotag",
		ft = {
			"html",
			"javascriptreact",
		},
		config = function()
			require("nvim-ts-autotag").setup()
		end,
	}

	use {
		"jose-elias-alvarez/null-ls.nvim",
		after = "nvim-lspconfig",
		config = function()
			require("custom.plugins.null-ls").setup()
		end,
	}

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
	--
	-- use {
	-- 	"Pocco81/TrueZen.nvim",
	-- 	cmd = {
	-- 		"TZAtaraxis",
	-- 		"TZMinimalist",
	-- 		"TZFocus",
	-- 	},
	-- 	config = function()
	-- 		require "custom.plugins.truezen"
	-- 	end,
	-- }
end)
