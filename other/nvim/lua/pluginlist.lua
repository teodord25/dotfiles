return {
	{
		'nvim-lualine/lualine.nvim',
		dependencies = {
			"nvim-tree/nvim-web-devicons"
		},
		config = function()
			require("lualine").setup({
				icons_enabled = true,
				theme = 'gruvbox',
			})
		end,
	},
	{
		"ellisonleao/gruvbox.nvim",
		priority = 1000,
		config = function()
			vim.cmd("colorscheme gruvbox")
		end
	},
	{
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
		end
	},

	"github/copilot.vim",

	"neovim/nvim-lspconfig",

	-- detect tabstop and shiftwidth automatically
	"tpope/vim-sleuth",

	"folke/neodev.nvim",

	{
		'folke/which-key.nvim',
		event = 'VimEnter',
		config = function()
			require('which-key').setup()
		end,
	},

	{
		'hrsh7th/nvim-cmp',
		dependencies = {
			'L3MON4D3/LuaSnip',
			'saadparwaiz1/cmp_luasnip',
			'rafamadriz/friendly-snippets',

			'hrsh7th/cmp-nvim-lsp',
		},
	},

	{
		'nvim-telescope/telescope.nvim',
		event = 'VimEnter',
		branch = '0.1.x',
		dependencies = {
			'nvim-lua/plenary.nvim',
			{ 'nvim-telescope/telescope-ui-select.nvim' },
			{ 'nvim-tree/nvim-web-devicons',            enabled = vim.g.have_nerd_font },
		},

		config = function()
			require('telescope').setup {
				extensions = {
					-- tells nvim to use telescope for stuff like code actions list
					['ui-select'] = {
						require('telescope.themes').get_dropdown(),
					},
				},
			}

			-- enable Telescope extensions if they are installed
			pcall(require('telescope').load_extension, 'ui-select')
		end,
	},
	{
		'nvim-treesitter/nvim-treesitter',
		dependencies = {
			{ "nushell/tree-sitter-nu" },
		},
		build = ':TSUpdate',
	},

	{ 'mbbill/undotree' },
	{ 'airblade/vim-gitgutter' },
	{
		'christoomey/vim-tmux-navigator',
		lazy = false,
	},

	{
		'windwp/nvim-autopairs',
		event = 'InsertEnter',
		config = true,
	},

	{
		'nvim-tree/nvim-tree.lua',
		config = true,
		opts = {},
	},
	{
		'lervag/vimtex',
		ft = { 'tex' },
	},
}
