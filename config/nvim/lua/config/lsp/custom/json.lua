vim.lsp.config.json_ls = {
	cmd = { "vscode-json-language-server" },
	filetypes = { "json" },
	root_markers = { ".git" },
}

vim.lsp.enable("json_ls")
