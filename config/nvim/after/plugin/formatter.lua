require("conform").setup({
  formatters_by_ft = {
    json = { "prettier" },
    python = { "ruff_fix", "ruff_format" },
    toml = { "taplo" },
  },
  formatters = {
    ruff_format = {
      args = { "format", "--stdin-filename", "$FILENAME", "-" },
    },
  },
  default_format_opts = {
    lsp_format = "fallback",
  },
})
