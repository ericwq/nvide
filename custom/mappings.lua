local map = require("core.utils").map

-- map('n', '<C-m>', ':Vista!!<CR>', opt) -- open/close
map("n", "<leader>fs", ":Telescope grep_string<CR>")
map("n", "<leader>ft", ":Telescope treesitter<CR>")
map("n", "<leader>j", ":SymbolsOutline<CR>")
-- NOTE: the 4th argument in the map function can be a table i.e options but its most likely un-needed so dont worry about it

--[[
-- telescope
map("n", "<leader>fp", ":Telescope media_files <CR>")
map("n", "<leader>te", ":Telescope <CR>")

-- truezen
map("n", "<leader>ta", ":TZAtaraxis <CR>")
map("n", "<leader>tm", ":TZMinimalist <CR>")
map("n", "<leader>tf", ":TZFocus <CR>")
--]]
