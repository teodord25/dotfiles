vim.lsp.config.nu = {
	cmd = { "nu", "--lsp" },
	filetypes = { "nu" },
	root_markers = { ".git" },
}

vim.lsp.enable("nu")
