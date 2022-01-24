-- This is the chadrc file , its supposed to be placed in /lua/custom dir
-- lua/custom/chadrc.lua
local M = {}

local pluginConfs = require "custom.plugins.configs"

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
    nvim_treesitter = pluginConfigs.treesitter,
    nvim_tree = pluginConfigs.nvimtree,
		--nvim_treesitter = "custom.plugins.treesitter",
		dashboard = "custom.plugins.dashboard",
		--nvim_tree = "custom.plugins.nvimtree",
	},
}

-- changing theme and UI
M.ui = {
	theme = "chadracula",
	italic_comments = true,
	transparency = true,
}

return M
