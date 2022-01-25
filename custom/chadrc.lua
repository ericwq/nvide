-- This is the chadrc file , its supposed to be placed in /lua/custom dir
-- lua/custom/chadrc.lua
local M = {}

local plugin_conf = require "custom.plugins.configs"

-- make sure you maintain the structure of `core/default_config.lua` here,

M.options = {
	expandtab = false,
	tabstop = 4,
	shiftwidth = 4,
}

M.plugins = {
	status = {
		dashboard = true,
		colorizer = true,
	},
	options = {
		lspconfig = {
			setup_lspconf = "custom.plugins.lspconfig",
		},
	},
	default_plugin_config_replace = {
		-- right side table value means replace part of the config
		nvim_treesitter = plugin_conf.treesitter,
		nvim_tree = plugin_conf.nvimtree,
		-- right side string value means replace the entire config
		dashboard = "custom.plugins.dashboard",
	},
}

-- changing theme and UI
M.ui = {
	theme = "chadracula",
	italic_comments = true,
	transparency = true,
}

return M
