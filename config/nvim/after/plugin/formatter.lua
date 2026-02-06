require("conform").setup({
  formatters_by_ft = {
    json = { "prettier" },
    python = { "ruff_format" },
  },
  formatters = {
    ruff_format = {
      args = { "format", "--line-length", "80", "--stdin-filename", "$FILENAME", "-" },
    },
  },
  default_format_opts = {
    lsp_format = "fallback",
  },
})
