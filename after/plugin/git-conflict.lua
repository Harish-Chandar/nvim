-- require'git-conflict'.setup {
--   default_mappings = {
--     ours = 'h',
--     theirs = 'l',
--     none = '0',
--     both = 'b',
--     next = 'j',
--     prev = 'k',
--   },
-- }

vim.keymap.set('n', 'ch', '<Plug>(git-conflict-ours)')
vim.keymap.set('n', 'cl', '<Plug>(git-conflict-theirs)')
vim.keymap.set('n', 'cb', '<Plug>(git-conflict-both)')
vim.keymap.set('n', 'cn', '<Plug>(git-conflict-none)')
vim.keymap.set('n', '[x', '<Plug>(git-conflict-prev-conflict)')
vim.keymap.set('n', ']x', '<Plug>(git-conflict-next-conflict)')
