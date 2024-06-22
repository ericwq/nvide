-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.o.clipboard = "unnamedplus"

-- https://github.com/neovim/neovim/discussions/28010
local function no_paste(reg)
  return function(lines)
    -- Do nothing! We can't paste with OSC52
  end
end

vim.g.clipboard = {
  name = "OSC 52",
  copy = {
    ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
    ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
  },
  paste = {
    ["+"] = no_paste("+"), -- Pasting disabled
    ["*"] = no_paste("*"), -- Pasting disabled
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
