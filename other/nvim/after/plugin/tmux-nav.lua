local nmap = vim.api.nvim_set_keymap

nmap('n', '<c-h>', '<cmd>TmuxNavigateLeft<cr>' , {})
nmap('n', '<c-l>', '<cmd>TmuxNavigateRight<cr>', {})
nmap('n', '<c-j>', '<cmd>TmuxNavigateDown<cr>' , {})
nmap('n', '<c-k>', '<cmd>TmuxNavigateUp<cr>'   , {})
