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


