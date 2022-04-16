-- -------
-- Library
-- -------

function map(mode, shortcut, command)
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

-- I don't care about tabs.
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- lualine setup
require('lualine').setup {
  options = {
    theme = 'tokyonight'
  }
}

-- bufferline setup
require("bufferline").setup{ }
nmap("[b", ":BufferLineCycleNext<cr>")
nmap("b]", ":BufferLineCyclePrev<cr>")
nmap("be", ":BufferLineSortByExtension<cr>")
nmap("bd", ":BufferLineSortByDirectory<cr>")

-- telescope setup
nmap("<leader>ff", ":Telescope find_files<cr>")
nmap("<leader>fg", ":Telescope live_grep<cr>")
nmap("<leader>fb", ":Telescope buffers<cr>")
nmap("<leader>fh", ":Telescope help_tags<cr>")

