vim.lsp.config('basedpyright', {
	settings = {
		basedpyright = {
			typeCheckingMode = "standard",
			analysis = {
				reportUnknownVariableType = "none",
				reportUnknownMemberType = "none",
				reportUnknownParameterType = "none",
				reportMissingTypeStubs = "none",
				reportAny = "none",
			}
		}
	}
})

vim.lsp.enable("basedpyright")
