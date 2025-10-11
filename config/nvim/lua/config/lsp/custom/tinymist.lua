vim.lsp.config.tinymist = {
	settings = {
		formatterMode = "typstyle",
		exportPdf = "onType",
		semanticTokens = "disable"
	}
}

vim.lsp.enable("tinymist")
