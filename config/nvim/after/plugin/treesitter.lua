require('nvim-treesitter.configs').setup {
	ensure_installed = { 'vim', 'vimdoc', 'lua', 'nix', 'nu' },

	auto_install = false,
	highlight = { enable = true },
	indent = { enable = true },
}
