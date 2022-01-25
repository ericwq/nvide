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
	use {
		"folke/which-key.nvim",
		disable = false,
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
		disable = true,
		after = "nvim-lspconfig",
		config = function()
			require("custom.plugins.symbols-outline")
		end,
	}

	-- tagviewer
	use {
		'liuchengxu/vista.vim',
		disable = true,
		event = "BufRead",
		-- run before this plugin is loaded.
		-- setup =
		-- run after this plugin is loaded.
		config = function()
			require("custom.plugins.vista")
		end,
	}

	-- use {
	-- 	"windwp/nvim-ts-autotag",
	-- 	ft = {
	-- 		"html",
	-- 		"javascriptreact",
	-- 	},
	-- 	config = function()
	-- 		require("nvim-ts-autotag").setup()
	-- 	end,
	-- }

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

	use {
		"neovim/nvim-lspconfig",
		module = "lspconfig",

		config = function()
			require "custom.plugins.lspconfig"
		end,

		-- lazy load!
		setup = function()
			require("core.utils").packer_lazy_load "nvim-lspconfig"
			vim.defer_fn(function()
				vim.cmd 'if &ft == "packer" | echo "" | else | silent! e %'
			end, 0)
		end,
		opt = true,
	}

	use {
		"ray-x/lsp_signature.nvim",
		after = "nvim-lspconfig",
		config = function()
			require "custom.plugins.signature"
		end,
	}

	-- Completion plugins, snippets!

	-- load luasnips + cmp related in insert mode only

	use {
		"rafamadriz/friendly-snippets",
		event = "InsertEnter",
	}

	use {
		"hrsh7th/nvim-cmp",
		after = "friendly-snippets",
		config = function()
			require "custom.plugins.cmp"
		end,
	}

	use {
		"L3MON4D3/LuaSnip",
		wants = "friendly-snippets",
		after = "nvim-cmp",
		config = function()
			local luasnip = require "luasnip"
			luasnip.config.set_config {
				history = true,
				updateevents = "TextChanged,TextChangedI",
			}
			require("luasnip/loaders/from_vscode").load()
		end,
	}

	use {
		"saadparwaiz1/cmp_luasnip",
		after = "LuaSnip",
	}

	use {
		"hrsh7th/cmp-nvim-lua",
		after = "cmp_luasnip",
	}

	use {
		"hrsh7th/cmp-nvim-lsp",
		after = "cmp-nvim-lua",
	}

	use {
		"hrsh7th/cmp-buffer",
		after = "cmp-nvim-lsp",
	}

	use {
		"hrsh7th/cmp-path",
		after = "cmp-buffer",
	}

	use {
		"windwp/nvim-autopairs",
		after = "nvim-cmp",
		config = function()
			local autopairs = require "nvim-autopairs"
			local cmp_autopairs = require "nvim-autopairs.completion.cmp"

			autopairs.setup {
				fast_wrap = {},
			}

			local cmp = require "cmp"
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	}
end)
