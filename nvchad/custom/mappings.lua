---@type MappingsTable
local M = {}

M.general = {
  n = {
    [";"] = { ":", "enter command mode", opts = { nowait = true } },
  },
}

M.telescope = {
	n = {
		["<leader>fs"] = {
			":Telescope grep_string<CR>",
			"   grep string",
		},
		["<leader>ft"] = {
			":Telescope treesitter<CR>",
			"   search symbol",
		},
	},
}

M.symbols_outline = {
	n = {
		["<leader>j"] = {
			"<cmd> :SymbolsOutline<CR>",
			"   List the symbols outline",
		},
	},
}

M.lspconfig = {
	n = {
		["<leader>b"] = {
			"<cmd> :ccl<CR>",
			"   Close quick fix window",
		},
	},
}

return M
