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

require 'lspconfig'.lua_ls.setup {
	on_attach = on_attach,
	capabilities = capabilities,

	on_init = function(client)
		client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
			runtime = { version = 'LuaJIT' },
			workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } }
		})
	end,

	settings = { Lua = {} }
}

require('lspconfig')["nushell"].setup {
	cmd       = { "nu", "--lsp" },
	filetypes = { "nu" },
	root_dir  = require('lspconfig.util').find_git_ancestor,
}

require 'lspconfig'.intelephense.setup {
	on_attach = on_attach,
	capabilities = capabilities,
}

require 'lspconfig'.ts_ls.setup {
	filetypes = {
		"javascript",
		"typescript",
	},
}

require("lspconfig")["tinymist"].setup {
	on_attach = on_attach,
	capabilities = capabilities,
	settings = {
		formatterMode = "typstyle",
		exportPdf = "onType",
		semanticTokens = "disable"
	}
}

require 'lspconfig'.gleam.setup {
	on_attach = on_attach,
	capabilities = capabilities,
}
require 'lspconfig'.gopls.setup {
	on_attach = on_attach,
	capabilities = capabilities,
}
require 'lspconfig'.pyright.setup {
	on_attach = on_attach,
	capabilities = capabilities,
}
require 'lspconfig'.nil_ls.setup {
	on_attach = on_attach,
	capabilities = capabilities,
}
require 'lspconfig'.rust_analyzer.setup {
	on_attach = on_attach,
	capabilities = capabilities,
}

require 'lspconfig'.clangd.setup {
	on_attach = on_attach,
	capabilities = capabilities,
}

require 'lspconfig'.wgsl_analyzer.setup({
	cmd = { vim.fn.expand("~/.cargo/bin/wgsl-analyzer") },
	filetypes = { "wgsl" },
	on_attach = on_attach,
	capabilities = capabilities,
})

require('lspconfig').vuels.setup {
	on_attach = on_attach,
	capabilities = capabilities,
	require('ls/vuels').default_config
}
