return {
  { -- https://github.com/simrat39/symbols-outline.nvim
    "simrat39/symbols-outline.nvim",
    event = "BufEnter",
    dependencies = {
      {
        "neovim/nvim-lspconfig",
      },
    },
    opts = {
      show_guides = false,
      auto_close = true,
      show_symbol_details = false,
      wrap = false,
      fold_markers = {
        "",
        "",
      },
    },
    config = function()
      require("symbols-outline").setup()
      -- You probably also want to set a keymap to toggle symbols outline
      vim.keymap.set("n", "<leader>j", "<cmd>SymbolsOutline<CR>")
    end,
  },
}
