vim.lsp.config.nu = {
	cmd = { "vscode-json-language-server" },
	filetypes = { "nu" },
	root_markers = { ".git" },
}

vim.lsp.enable("jsonls")
