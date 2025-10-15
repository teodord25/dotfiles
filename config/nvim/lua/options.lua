-- disable netrw for nvimtree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.have_nerd_font = true

vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = 'a'

vim.o.wrap = false

-- don't show mode because its already in the status line
vim.o.showmode = false

-- enable break indent
vim.o.breakindent = true

-- save undo history
vim.o.undofile = true

vim.o.updatetime = 300
vim.o.timeoutlen = 300 -- for which key

vim.o.signcolumn = 'yes'

vim.o.colorcolumn = '80'

vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true

vim.o.termguicolors = true

vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '☣' }

vim.cmd [[
    highlight SpecialKey guifg=red ctermfg=red
    highlight NonText   guifg=red ctermfg=red
]]

-- preview subsititutions as you type ?
vim.o.inccommand = 'split'

vim.o.cursorline = true

-- minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10

-- highlight on search
vim.o.hlsearch = true
