local on_attach = function(_, buffer)
	local bufmap = function(keys, func)
		vim.keymap.set('n', keys, func, { buffer = buffer })
	end

	bufmap('<leader>r', vim.lsp.buf.rename)
	bufmap('<leader>a', vim.lsp.buf.code_action)

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