vim.lsp.config.wgsl_analyzer = {
	cmd = { vim.fn.expand("~/.cargo/bin/wgsl-analyzer") },
	filetypes = { "wgsl" },
}

vim.lsp.enable("wgsl_analyzer")
