return {
  {
    import = "lazyvim.plugins.extras.lang.go",
  },
  {
    import = "lazyvim.plugins.extras.lang.clangd",
  },
  {
    import = "lazyvim.plugins.extras.editor.aerial",
  },
  {
    import = "lazyvim.plugins.extras.ui.treesitter-context",
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          mason = false,
        },
        gopls = {
          mason = false,
        },
      },
    },
  },
}
