-- source a vimscript file for clipboard support
vim.cmd('source ~/.config/nvim/vimrc')

-----------------------------------------------------------
-- Neovim provider
-----------------------------------------------------------
vim.g.loaded_python3_provider = 1 -- enable python 3 provider
vim.g.python3_host_prog = '/usr/bin/python3'

vim.opt.expandtab = false
vim.opt.tabstop = 3
vim.opt.shiftwidth = 3
