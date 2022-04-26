-- -------
-- Library
-- -------

function map (mode, shortcut, command)
vim.api.nvim_set_keymap(mode, shortcut, command, { noremap = true, silent = true })
end
function nmap(shortcut, command)
map('n', shortcut, command)
end
function imap(shortcut, command)
map('i', shortcut, command)
end

-- ------
-- Config
-- ------

vim.cmd([[
set nobackup
set number
set termguicolors " 24-bit colors
" let g:tokyonight_style = "day"
" let g:tokyonight_italic_functions = 1
" colorscheme tokyonight
" colorscheme sonokai
colorscheme PaperColor
]])

-- I don't care about tabs.
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true


