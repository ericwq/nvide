-- This is the chadrc file , its supposed to be placed in /lua/custom dir
-- lua/custom/chadrc.lua
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
	-- status = {
	-- 	alpha = true,
	-- 	colorizer = true,
	-- },
	options = {
		lspconfig = {
			setup_lspconf = "custom.plugins.lspconfig",
		},
	},
	override = {
		-- right side table value means replace part of the config
		["nvim-treesitter/nvim-treesitter"] = plugin_conf.treesitter,
		["kyazdani42/nvim-tree.lua"] = plugin_conf.nvimtree,
		-- right side string value means replace the entire config
		-- alpha = "custom.plugins.alpha",
	},

	-- add, modify, remove plugins
	user = userPlugins,
}

-- changing theme and UI
M.ui = {
	theme = "chadracula",
	italic_comments = true,
	transparency = true,
}

return M
