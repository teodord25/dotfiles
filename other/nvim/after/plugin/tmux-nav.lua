local nmap = vim.api.nvim_set_keymap

nmap('n', '<C-h>', '<cmd>TmuxNavigateLeft<cr>' , {})
nmap('n', '<C-l>', '<cmd>TmuxNavigateRight<cr>', {})
nmap('n', '<C-j>', '<cmd>TmuxNavigateDown<cr>' , {})
nmap('n', '<C-k>', '<cmd>TmuxNavigateUp<cr>'   , {})
