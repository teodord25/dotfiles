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