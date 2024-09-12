require('telescope').setup()

local nmap = vim.api.nvim_set_keymap
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

nmap('n', '<leader>sf', '<cmd>Telescope find_files<cr>', opts)
nmap('n', '<leader>sg', '<cmd>Telescope live_grep<cr>', opts)
nmap('n', '<leader>sb', '<cmd>Telescope buffers<cr>', opts)
nmap('n', '<leader>sh', '<cmd>Telescope help_tags<cr>', opts)

nmap('n', '<leader>sc', '<cmd>Telescope colorscheme<cr>', opts)
nmap('n', '<leader>sm', '<cmd>Telescope marks<cr>', opts)
nmap('n', '<leader>sr', '<cmd>Telescope oldfiles<cr>', opts)

local builtin = require 'telescope.builtin'
map('n', '<leader>sn', function()
    builtin.find_files { cwd = vim.fn.stdpath 'config' }
end, { desc = '[S]earch [N]eovim files' })
