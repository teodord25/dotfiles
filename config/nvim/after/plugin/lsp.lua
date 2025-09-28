local on_attach = function(client, buffer)
	-- disable buggy semantic tokens for Typst (Tinymist)
	if client.name == "tinymist" then
		client.server_capabilities.semanticTokensProvider = nil
	end

	print("attached " .. client.name)
	local bufmap = function(keys, func)
		vim.keymap.set('n', keys, func, { buffer = buffer })
	end

	bufmap('<leader>r', vim.lsp.buf.rename)
	bufmap('<leader>ca', vim.lsp.buf.code_action)

	bufmap('gd', vim.lsp.buf.definition)
	bufmap('gD', vim.lsp.buf.declaration)
	bufmap('gI', vim.lsp.buf.implementation)
	bufmap('<leader>D', vim.lsp.buf.type_definition)

	bufmap('K', vim.lsp.buf.hover)

	bufmap('gr', require('telescope.builtin').lsp_references)
	bufmap('<leader>s', require('telescope.builtin').lsp_document_symbols)
	bufmap('<leader>S', require('telescope.builtin').lsp_dynamic_workspace_symbols)

	bufmap('<leader>f', vim.lsp.buf.format)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

local lsps = {
	{ "rust_analyzer" },
	{ "clangd" },

	{ "wgsl_analyzer", {
		cmd = { vim.fn.expand("~/.cargo/bin/wgsl-analyzer") },
		filetypes = { "wgsl" },
	} },

	{ "lua_ls" },

	{ "intelephense" },
	{ "ts_ls",       { filetypes = { "javascript", "typescript" } } },
	{ "gleam" },
	{ "gopls" },
	{ "basedpyright" },
	{ "nil_ls" },

	{ "nushell", {
		cmd = { "nu", "--lsp" },
		filetypes = { "nu" },
		root_markers = { ".git" },
	} },

	{ "tinymist", {
		settings = {
			formatterMode = "typstyle",
			exportPdf = "onType",
			semanticTokens = "disable"
		}
	} },
}

for _, lsp in pairs(lsps) do
	local name, config = lsp[1], lsp[2]

	if config then
		vim.lsp.config(name, config)
	end

	vim.lsp.enable(name)
end

vim.lsp.config('*', {
	capabilities = require('cmp_nvim_lsp').default_capabilities(),
	on_attach = on_attach
})
