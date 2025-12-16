vim.lsp.config.cs_ls = {
	cmd = { 
		"Microsoft.CodeAnalysis.LanguageServer",
		"--logLevel", "Information",
		"--extensionLogDirectory", vim.fn.stdpath("cache") .. "/roslyn_logs"
	},
	filetypes = { "cs" },
	root_markers = { ".git", "*.sln", "*.csproj" },
}

vim.lsp.enable("cs_ls")
