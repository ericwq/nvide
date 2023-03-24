-- @type ChadrcConfig
local M = {}

-- Path to overriding theme and highlights files
local highlights = require "custom.highlights"

-- changing theme and UI
M.ui = {
	theme = "chadracula",
	theme_toggle = {
		"chadracula",
		"onedark",
		"one_light",
	},

	hl_override = highlights.override,
	hl_add = highlights.add,

	-- hl_override = {
	-- 	Comment = {
	-- 		fg = "#808080",
	-- 		italic = true,
	-- 	},
	-- },
	transparency = true,
}

-- M.plugins = "custom.plugins"

-- check core.mappings for table structure
M.mappings = require "custom.mappings"

return M
