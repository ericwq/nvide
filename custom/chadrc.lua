-- This is the chadrc file , its supposed to be placed in /lua/custom dir
-- lua/custom/chadrc.lua
-- remove this if you dont use custom.init.lua at all
local M = {}

-- make sure you maintain the structure of `core/default_config.lua` here,
M.plugins = require "custom.plugins"

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
