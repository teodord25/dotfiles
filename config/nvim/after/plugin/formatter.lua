require("conform").setup({
  formatters_by_ft = {
    json = { "prettier" },
  },

  default_format_opts = {
    lsp_format = "fallback", -- use LSP when formatter isnt set
  },
})
