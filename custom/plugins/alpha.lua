local present, alpha = pcall(require, "alpha")

if not present then
	return
end

local ascii = {
	"",
	"",
	"",
	"",
	"",
	"ooooo      ooo oooooo     oooo ooooo oooooooooo.   oooooooooooo",
	"`888b.     `8'  `888.     .8'  `888' `888'   `Y8b  `888'     `8",
	" 8 `88b.    8    `888.   .8'    888   888      888  888        ",
	" 8   `88b.  8     `888. .8'     888   888      888  888oooo8   ",
	" 8     `88b.8      `888.8'      888   888      888  888    '   ",
	" 8       `888       `888'       888   888     d88'  888       o",
	"o8o        `8        `8'       o888o o888bood8P'   o888ooooood8",
}

local header = {
	type = "text",
	val = ascii,
	opts = {
		position = "center",
		hl = "AlphaHeader",
	},
}

local function button(sc, txt, keybind)
	local sc_ = sc:gsub("%s", ""):gsub("SPC", "<leader>")

	local opts = {
		position = "center",
		text = txt,
		shortcut = sc,
		cursor = 5,
		width = 36,
		align_shortcut = "right",
		hl = "AlphaButtons",
	}

	if keybind then
		opts.keymap = {
			"n",
			sc_,
			keybind,
			{
				noremap = true,
				silent = true,
			},
		}
	end

	return {
		type = "button",
		val = txt,
		on_press = function()
			local key = vim.api.nvim_replace_termcodes(sc_, true, false, true)
			vim.api.nvim_feedkeys(key, "normal", false)
		end,
		opts = opts,
	}
end

local buttons = {
	type = "group",
	val = {
		button("SPC f f", "  Find File  ", ":Telescope find_files<CR>"),
		button("SPC f o", "  Recent File  ", ":Telescope oldfiles<CR>"),
		button("SPC f w", "  Find Word  ", ":Telescope live_grep<CR>"),
		button("SPC b m", "  Bookmarks  ", ":Telescope marks<CR>"),
		button("SPC t h", "  Themes  ", ":Telescope themes<CR>"),
		button("SPC e s", "  Settings", ":e $MYVIMRC | :cd %:p:h <CR>"),
	},
	opts = {
		spacing = 1,
	},
}

local nvide_msg = {
	"Lua, C/C++ and Golang Integrated Development Environment.",
	"",
	"        Powered by sumneko_lua, gopls and clangd.",
}

local footer = {
	type = "text",
	val = nvide_msg,
	opts = {
		position = "center",
		hl = "hl_group",
	},
}

local section = {
	header = header,
	buttons = buttons,
	footer = footer,
}

alpha.setup {
	layout = {
		{
			type = "padding",
			val = 5,
		},
		section.header,
		{
			type = "padding",
			val = 2,
		},
		section.buttons,
		{
			type = "padding",
			val = 5,
		},
		section.footer,
	},
	opts = {},
}
