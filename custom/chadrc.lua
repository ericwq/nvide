-- This is the chadrc file , its supposed to be placed in /lua/custom dir
-- lua/custom/chadrc.lua
-- remove this if you dont use custom.init.lua at all
require "custom"

local M = {}

local pluginConfs = require "custom.plugins.configs"
-- local userPlugins = require "custom.plugins"

-- make sure you maintain the structure of `core/default_config.lua` here,
M.plugins = {
	-- user = {
	-- 	["neovim/nvim-lspconfig"] = {
	-- 		opt = true,
	-- 		setup = function()
	-- 			require("core.lazy_load").on_file_open "nvim-lspconfig"
	-- 		end,
	-- 		config = function()
	-- 			require "plugins.configs.lspconfig"
	-- 			require "custom.plugins.lspconfig"
	-- 		end,
	-- 	},
	-- 	["jose-elias-alvarez/null-ls.nvim"] = {
	-- 		after = "nvim-lspconfig",
	-- 		config = function()
	-- 			require("custom.plugins.null-ls").setup()
	-- 		end,
	-- 	},
	-- },

	-- add plugins, modify plugin definition options
	user = require("custom.plugins"),
	-- options = {
	-- 	lspconfig = {
	-- 		setup_lspconf = "custom.plugins.lspconfig",
	-- 	},
	-- },

	-- override default config of a plugin
	override = {
		["nvim-treesitter/nvim-treesitter"] = pluginConfs.treesitter,
		["kyazdani42/nvim-tree.lua"] = pluginConfs.nvimtree,
		["williamboman/nvim-lsp-installer"] = pluginConfs.lspinstaller,
		["lukas-reineke/indent-blankline.nvim"] = pluginConfs.blankline,
	},
	status = {
		colorizer = true,
	},
}

-- changing theme and UI
M.ui = {
	theme = "chadracula",
	hl_override = {
		Comment = {
			fg = "#808080",
			italic = true,
		},
	},
	transparency = true,
}

M.mappings = require "custom.mappings"

return M
