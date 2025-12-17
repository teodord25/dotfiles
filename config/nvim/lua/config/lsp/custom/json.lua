vim.lsp.config.json_ls = {
	cmd = { "vscode-json-language-server", "--stdio" },
	filetypes = { "json" },
	root_markers = { ".git" },
}

vim.lsp.enable("json_ls")
