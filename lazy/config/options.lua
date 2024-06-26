-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- https://github.com/neovim/neovim/discussions/28010
--
-- local function no_paste(_)
--   return function(_)
--   end
-- end
vim.o.clipboard = "unnamedplus"

local function paste()
  return {
    vim.fn.split(vim.fn.getreg(""), "\n"),
    vim.fn.getregtype(""),
  }
end

vim.g.clipboard = {
  name = "OSC 52",
  copy = {
    ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
    ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
  },
  paste = {
    ["+"] = paste,
    ["*"] = paste,
    -- ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
    -- ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
  },
}

-- local function copy(lines, _)
--   require("osc52").copy(table.concat(lines, "\n"))
-- end
--
-- local function paste()
--   return {
--     vim.fn.split(vim.fn.getreg(""), "\n"),
--     vim.fn.getregtype(""),
--   }
-- end
--
-- vim.g.clipboard = {
--   name = "osc52",
--   copy = {
--     ["+"] = copy,
--     ["*"] = copy,
--   },
--   paste = {
--     ["+"] = paste,
--     ["*"] = paste,
--   },
-- }

-- disable language provider support (lua and vimscript plugins only)
--
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
-- vim.g.loaded_node_provider = 0
-- vim.g.loaded_python_provider = 0
-- vim.g.loaded_python3_provider = 0
