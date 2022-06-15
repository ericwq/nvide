-- This is the chadrc file , its supposed to be placed in /lua/custom dir
-- lua/custom/chadrc.lua
-- remove this if you dont use custom.init.lua at all
require "custom"

local M = {}

local plugin_conf = require "custom.plugins.configs"
local userPlugins = require "custom.plugins"

-- make sure you maintain the structure of `core/default_config.lua` here,

M.options = {
	user = function()
		vim.opt.expandtab = false
		vim.opt.tabstop = 4
		vim.opt.shiftwidth = 4
	end,
}

M.plugins = {
	options = {
		lspconfig = {
			setup_lspconf = "custom.plugins.lspconfig",
		},
	},
	override = {
		["nvim-treesitter/nvim-treesitter"] = plugin_conf.treesitter,
		["kyazdani42/nvim-tree.lua"] = plugin_conf.nvimtree,
		["williamboman/nvim-lsp-installer"] = plugin_conf.lspinstaller,
	},

	-- add, modify, remove plugins
	user = userPlugins,
}

-- changing theme and UI
M.ui = {
	theme = "chadracula",
	hl_override = {
		Comment = {
			fg = "#444444",
			italic = true,
		},
	},
	transparency = true,
}

M.mappings = require "custom.mappings"

return M
