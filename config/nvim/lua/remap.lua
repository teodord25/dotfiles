local map = vim.keymap.set
local nmap = vim.api.nvim_set_keymap

map('n', '<Esc>', '<cmd>nohlsearch<CR>')

map('n', '[d'       , vim.diagnostic.goto_prev , { desc = 'Go to previous [D]iagnostic message' })
map('n', ']d'       , vim.diagnostic.goto_next , { desc = 'Go to next [D]iagnostic message'     })
map('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages'    })
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list'     })

map('n', '<leader>dd', function()
    vim.diagnostic.enable(false)
end, { desc = 'Disable diagnostics' })

map('n', '<leader>ed', function()
    vim.diagnostic.enable(true)
end, { desc = 'Enable diagnostics' })

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

vim.keymap.set("n", "<leader>yj", function()
  local root = vim.fs.root(0, ".git") or vim.uv.cwd()
  local rel = vim.api.nvim_buf_get_name(0):gsub("^" .. vim.pesc(root) .. "/", "")
  local url = ("jetbrains://pycharm/navigate/reference?project=%s&path=%s:%d:%d")
    :format(vim.fn.fnamemodify(root, ":t"), rel, vim.fn.line("."), vim.fn.col(".") - 1)
  vim.fn.setreg("+", url)
end, { desc = "Copy PyCharm deep link" })
