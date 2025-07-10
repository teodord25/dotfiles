return {
	"j-hui/fidget.nvim",
	{
		"sylvanfranklin/omni-preview.nvim",
		dependencies = {
			-- Typst
			{ 'chomosuke/typst-preview.nvim', lazy = true },
			-- CSV
			{ 'hat0uma/csvview.nvim',         lazy = true },
		},
		opts = {},
		keys = {
			{ "<leader>po", "<cmd>OmniPreview start<CR>", desc = "OmniPreview Start" },
			{ "<leader>pc", "<cmd>OmniPreview stop<CR>",  desc = "OmniPreview Stop" },
		},
	},
	{
		"mfussenegger/nvim-jdtls",
		ft = "java", -- Load this plugin for Java files
		config = function()
			local jdtls = require("jdtls")
			local root_dir = jdtls.setup.find_root({ ".git", "pom.xml", "build.gradle" })
			local config = {
				cmd = { "jdtls", "-data", "/path/to/your/workspace" },
				root_dir = root_dir,
				settings = {
					java = {
						-- Add your Java settings here
					}
				}
			}
			jdtls.start_or_attach(config)
		end
	},
	{
		"mfussenegger/nvim-lint",
		lazy = true,
		event = { "BufReadPre", "BufNewFile" }, -- to disable, comment this out
		config = function()
			local lint = require("lint")
			lint.linters_by_ft = {
				-- javascript = { "eslint_d" },
				-- typescript = { "eslint_d" },
				-- vue = { "eslint_d" },
				go = { "golangcilint" },
			}
			local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
			-- vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			-- group = lint_augroup,
			-- callback = function()
			-- lint.try_lint()
			-- end,
			-- })
			vim.keymap.set("n", "<leader>li", function()
				lint.try_lint()
			end, { desc = "Trigger linting for current file" })
		end,
	},
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
	"mbbill/undotree",
	{
		"ThePrimeagen/harpoon",
		dependencies = { "nvim-lua/plenary.nvim" },
	},

	-- "neoclide/coc.nvim",

	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			signs = true,
			sign_priority = 8,

			keywords = {
				FIX = {
					icon = " ",
					color = "error",
					alt = { "FIXME", "BUG", "FIXIT", "ISSUE" },
				},
				TODO = { icon = " ", color = "info" },
				HACK = { icon = " ", color = "warning", alt = { "BLACKMAGIC" } },
				WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
				PERF = { icon = " ", color = "default", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
				NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
				TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
			},
			gui_style = {
				fg = "NONE",         -- The gui style to use for the fg highlight group.
				bg = "BOLD",         -- The gui style to use for the bg highlight group.
			},
			merge_keywords = true,   -- when true, custom keywords will be merged with the defaults
			highlight = {
				multiline = true,    -- enable multine todo comments
				multiline_pattern = "^.", -- lua pattern to match the next multiline from the start of the matched keyword
				multiline_context = 10, -- extra lines that will be re-evaluated when changing a line
				before = "",         -- "fg" or "bg" or empty
				keyword = "wide",
				after = "fg",        -- "fg" or "bg" or empty
				pattern = [[.*<(KEYWORDS)\s*:]], -- pattern or table of patterns, used for highlighting (vim regex)
				comments_only = true, -- uses treesitter to match keywords in comments only
				max_line_len = 400,  -- ignore lines longer than this
				exclude = {},        -- list of file types to exclude highlighting
			},
			-- list of named colors where we try to extract the guifg from the
			-- list of highlight groups or use the hex color if hl not found as a fallback
			colors = {
				error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
				warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
				info = { "DiagnosticInfo", "#2563EB" },
				hint = { "DiagnosticHint", "#10B981" },
				default = { "Identifier", "#7C3AED" },
				test = { "Identifier", "#FF00FF" }
			},
			search = {
				command = "rg",
				args = {
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
				},
				pattern = [[\b(KEYWORDS):]], -- ripgrep regex
			},
		}

		-- TODO: asdf
	},

	-- detect tabstop and shiftwidth automatically
	-- "tpope/vim-sleuth",

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
		"christoomey/vim-tmux-navigator",
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
		"lervag/vimtex",
		lazy = false, -- we don't want to lazy load VimTeX
		config = function()
			vim.g.vimtex_view_method = "zathura"
			vim.g.vimtex_compiler_method = "latexmk"
		end
	}
}
