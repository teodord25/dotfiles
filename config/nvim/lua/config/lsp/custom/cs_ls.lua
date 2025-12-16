vim.lsp.config.omnisharp_roslyn = {
	cmd = { "OmniSharp" },
	filetypes = { "cs" },
	root_markers = { ".git", "*.sln", "*.csproj" },
}

vim.lsp.enable("omnisharp_roslyn")
