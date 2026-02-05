require("conform").setup({
  formatters_by_ft = {
    json = { "prettier" },
    python = { "ruff_format" },
  },

  default_format_opts = {
    lsp_format = "fallback", -- use LSP when formatter isnt set
  },

  formatters = {
    ruff_format = {
      prepend_args = { "--line-length", "80" },
    },
  },
})
