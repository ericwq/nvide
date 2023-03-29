-- local autocmd = vim.api.nvim_create_autocmd
-- Auto resize panes when resizing nvim window
-- autocmd("VimResized", {
--   pattern = "*",
--   command = "tabdo wincmd =",
-- })
-- source a vimscript file for clipboard support
vim.cmd('source ~/.config/nvim/vimrc')

-----------------------------------------------------------
-- Neovim provider
-----------------------------------------------------------
local enable_providers = {
	"python3_provider",
	"node_provider",
	-- and so on
}

for _, plugin in pairs(enable_providers) do
	vim.g["loaded_" .. plugin] = nil
	vim.cmd("runtime " .. plugin)
end
-- vim.g.loaded_python3_provider = nil -- enable python 3 provider
vim.g.python3_host_prog = '/usr/bin/python3'

vim.opt.expandtab = false
vim.opt.tabstop = 3
vim.opt.shiftwidth = 3
