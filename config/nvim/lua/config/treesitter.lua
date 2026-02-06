-- TODO: move everything into /lua/config
-- and then require() each setup file in
-- each appropriate plugin declaration

require('nvim-treesitter').setup({
	ensure_installed = { 'vim', 'vimdoc', 'lua', 'nix', 'nu' },
	auto_install = false,
	highlight = { enable = true },
	indent = { enable = true },
})

vim.filetype.add({
	filename = {
		['tridactylrc'] = 'vim',
	},
	pattern = {
		['.*%.tridactylrc'] = 'vim',
	},
})
