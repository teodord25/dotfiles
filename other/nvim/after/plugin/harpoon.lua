local harpoon_mark = require('harpoon.mark')
local harpoon_ui = require('harpoon.ui')

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

map('n', '<leader>a', function() harpoon_mark.add_file() end, opts)
map('n', '<C-e>', function() harpoon_ui.toggle_quick_menu() end, opts)

map('n', '<M-h>', function() harpoon_ui.nav_file(1) end, opts)
map('n', '<M-j>', function() harpoon_ui.nav_file(2) end, opts)
map('n', '<M-k>', function() harpoon_ui.nav_file(3) end, opts)
map('n', '<M-l>', function() harpoon_ui.nav_file(4) end, opts)
