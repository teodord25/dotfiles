vim.lsp.config.omnisharp = {
	cmd = { "OmniSharp",  "-lsp" },
	filetypes = { "cs" },
	root_markers = { "*.csproj" },
}

vim.lsp.enable("omnisharp")
