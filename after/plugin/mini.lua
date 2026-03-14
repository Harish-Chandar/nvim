-- mini.nvim configuration

-- mini.indentscope - Visual indentation guides
require('mini.indentscope').setup({
	symbol = '│',
	options = {
		try_as_border = true,
	},
	draw = {
		animation = require('mini.indentscope').gen_animation.none(),
	},
})

-- mini.move - Move selections with arrow keys or Alt+hjkl
require('mini.move').setup()

-- mini.pairs - Autopairs
require('mini.pairs').setup()
