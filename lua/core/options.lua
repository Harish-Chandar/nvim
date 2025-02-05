vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

vim.opt.relativenumber = true 
vim.opt.number = true
vim.opt.cursorline = true

vim.opt.autowrite = true -- save the file before leaving if changed
vim.opt.autoread = true  -- auto load file changes occured outside vim

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

-- Sync system and nvim clipboard
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

vim.opt.breakindent = true -- Enable break indent

vim.opt.ignorecase = true  -- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.smartcase = true

vim.api.nvim_create_autocmd("TextYankPost", {
  pattern = "*",
  callback = function()
    vim.highlight.on_yank { higroup = "Visual", timeout = 250 }
  end,
  desc = "Highlight text on yank",
})

