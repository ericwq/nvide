-- This is an custom init file , its supposed to be placed in /lua/custom/
-- This is where your custom modules and plugins go.
-- Please check NvChad docs if you're totally new to nvchad + dont know lua!!
-- MAPPINGS
local map = require("core.utils").map

-- map('n', '<C-m>', ':Vista!!<CR>', opt) -- open/close
map("n", "<leader>fs", ":Telescope grep_string<CR>")
map("n", "<leader>ft", ":Telescope treesitter<CR>")
-- NOTE: the 4th argument in the map function can be a table i.e options but its most likely un-needed so dont worry about it

-- Install plugins
local customPlugins = require "core.customPlugins"

customPlugins.add(function(use)
	-- A fast and lua alternative to filetype.vim
	-- https://github.com/nathom/filetype.nvim
	-- use ':echo &filetype' to detect the corrrect file type
	-- use `:set filetype=langname` to set file type.
	use {
		'nathom/filetype.nvim',
		event = "VimEnter",
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

	-- null-ls
	use {
		"jose-elias-alvarez/null-ls.nvim",
		after = "nvim-lspconfig",
		requires = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			require("custom.plugins.null-ls")
		end,
	}

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
		disable = true,
		event = "VimEnter",
		config = function()
			require("which-key").setup {
				-- your configuration comes here
				-- or leave it empty to use the default settings
				-- refer to the configuration section below
			}
		end,
	}

end)

-- NOTE: we heavily suggest using Packer's lazy loading (with the 'event','cmd' fields)
-- see: https://github.com/wbthomason/packer.nvim
-- https://nvchad.github.io/config/walkthrough

-- try to call the customized provider
pcall(require, "custom.plugins.provider")
