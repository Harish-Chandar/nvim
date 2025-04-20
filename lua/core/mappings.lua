vim.g.mapleader = " "
vim.keymap.set('n', '<leader>e', '<cmd>Neotree toggle<CR>', { noremap = true, silent = true })

-- Navigate to the previous/next buffer
vim.keymap.set('n', '[b', '<cmd>bprevious<CR>', { noremap = true, silent = true })
vim.keymap.set('n', ']b', '<cmd>bnext<CR>', { noremap = true, silent = true })

vim.keymap.set('n', '<leader>bd', '<cmd>bd<CR>', { noremap = true, silent = true })

vim.keymap.set('n', '<leader>w', function() vim.wo.wrap = not vim.wo.wrap end, { desc = "Toggle Word Wrap" })

vim.api.nvim_set_keymap('i', '<Tab>', 'v:lua.vim.lsp.omnifunc', {expr = true, noremap = true})
