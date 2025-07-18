local map = vim.keymap.set
local nmap = vim.api.nvim_set_keymap

map('n', '<Esc>', '<cmd>nohlsearch<CR>')

map('n', '[d'       , vim.diagnostic.goto_prev , { desc = 'Go to previous [D]iagnostic message' })
map('n', ']d'       , vim.diagnostic.goto_next , { desc = 'Go to next [D]iagnostic message'     })
map('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages'    })
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list'     })
map('n', '<C-h>'    , '<C-w><C-h>'             , { desc = 'Move focus to the left window'       })
map('n', '<C-l>'    , '<C-w><C-l>'             , { desc = 'Move focus to the right window'      })
map('n', '<C-j>'    , '<C-w><C-j>'             , { desc = 'Move focus to the lower window'      })
map('n', '<C-k>'    , '<C-w><C-k>'             , { desc = 'Move focus to the upper window'      })
map('x', "<leader>p", [["_dP]]                 , { desc = 'Paste from clipboard'                })
map('n', "<leader>Y", [["+Y]]                  , { desc = 'Yank to clipboard'                   })


nmap('n', '<c-h>', '<cmd>TmuxNavigateLeft<cr>' , {})
nmap('n', '<c-l>', '<cmd>TmuxNavigateRight<cr>', {})
nmap('n', '<c-j>', '<cmd>TmuxNavigateDown<cr>' , {})
nmap('n', '<c-k>', '<cmd>TmuxNavigateUp<cr>'   , {})

map({'n', 'v'}, "<leader>y", [["+y]])

nmap('n', '<C-n>', ':cnext<CR>', {
	desc = 'Go to next item in quickfix list',
	noremap = true,
	silent = true
})

nmap('n', '<C-p>', ':cprev<CR>', {
	desc = 'Go to next item in quickfix list',
	noremap = true,
	silent = true
})

map('n', '<C-a>', '`A', { desc = 'Jump to global mark A' })
map('n', '<C-s>', '`S', { desc = 'Jump to global mark S' })
map('n', '<C-d>', '`D', { desc = 'Jump to global mark D' })
map('n', '<C-f>', '`F', { desc = 'Jump to global mark F' })
