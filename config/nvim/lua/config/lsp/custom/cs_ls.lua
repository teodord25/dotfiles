vim.lsp.config.cs_ls = {
	cmd = { "Microsoft.CodeAnalysis.LanguageServer" },
	filetypes = { "cs" },
	root_markers = { ".git" },
}

vim.lsp.enable("cs_ls")
