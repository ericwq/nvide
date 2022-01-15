local g = vim.g

g.dashboard_disable_at_vimenter = 0
g.dashboard_disable_statusline = 1
g.dashboard_default_executive = "telescope"
g.dashboard_custom_header = {

   [[]],
   [[]],
   [[]],
   [[]],
   [[]],
   [[]],
   [[ooooo      ooo oooooo     oooo ooooo oooooooooo.   oooooooooooo]],
   [[`888b.     `8'  `888.     .8'  `888' `888'   `Y8b  `888'     `8]],
   [[ 8 `88b.    8    `888.   .8'    888   888      888  888        ]],
   [[ 8   `88b.  8     `888. .8'     888   888      888  888oooo8   ]],
   [[ 8     `88b.8      `888.8'      888   888      888  888    "   ]],
   [[ 8       `888       `888'       888   888     d88'  888       o]],
   [[o8o        `8        `8'       o888o o888bood8P'   o888ooooood8]],
}

g.dashboard_custom_section = {
   a = { description = { "  Find File                 SPC f f" }, command = "Telescope find_files" },
   b = { description = { "  Recents                   SPC f o" }, command = "Telescope oldfiles" },
   c = { description = { "  Find Word                 SPC f w" }, command = "Telescope live_grep" },
   d = { description = { "洛 New File                  SPC f n" }, command = "DashboardNewFile" },
   e = { description = { "  Bookmarks                 SPC b m" }, command = "Telescope marks" },
   f = { description = { "  Load Last Session         SPC l  " }, command = "SessionLoad" },
   g = { description = { "  Check health                     " }, command = "checkhealth" },
--   h = { description = { "  Update Plugins                   " }, command = "PackerSync" },
}

g.dashboard_custom_footer = {
   "C/C++ and Golang Integrated Development Environment.",
   "",
   "      Powered by sumneko_lua, gopls and clangd.",
}
