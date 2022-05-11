local map = nvchad.map

-- map('n', '<C-m>', ':Vista!!<CR>', opt) -- open/close
map("n", "<leader>fs", ":Telescope grep_string<CR>")
map("n", "<leader>ft", ":Telescope treesitter<CR>")
map("n", "<leader>j", "<cmd> :SymbolsOutline<CR>")
map("n", "<leader>b", "<cmd> :ccl<CR>")

-- telescope
-- map("n", "<leader>fp", ":Telescope media_files <CR>")
-- map("n", "<leader>te", ":Telescope <CR>")

-- truezen
-- map("n", "<leader>ta", ":TZAtaraxis <CR>")
-- map("n", "<leader>tm", ":TZMinimalist <CR>")
-- map("n", "<leader>tf", ":TZFocus <CR>")
