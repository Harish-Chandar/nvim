local builtin = require('telescope.builtin')

vim.keymap.set('n', '<leader> ', builtin.find_files, {})
vim.keymap.set('n', '<leader>ff', function()
	builtin.find_files({
		find_command = { 'git', 'ls-files', '--others', '--ignored', '--exclude-standard' },
	})
end, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
