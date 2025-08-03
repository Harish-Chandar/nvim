local harpoon = require("harpoon")

harpoon:setup({
	settings = {
		save_on_toggle = true,
		sync_on_ui_close = true,
	}
})

-- Get the Harpoon list
local list = harpoon:list()

vim.keymap.set("n", "<Leader>a", function()
	list:add()
end, { desc = "Harpoon: Add file" })

vim.keymap.set("n", "<Leader>m", function()
	harpoon.ui:toggle_quick_menu(list)
end, { desc = "Harpoon: Toggle quick menu" })

vim.keymap.set("n", "<Leader>1", function()
	list:select(1)
end, { desc = "Harpoon: Go to file 1" })

vim.keymap.set("n", "<Leader>2", function()
	list:select(2)
end, { desc = "Harpoon: Go to file 2" })

vim.keymap.set("n", "<Leader>3", function()
	list:select(3)
end, { desc = "Harpoon: Go to file 3" })

vim.keymap.set("n", "<Leader>4", function()
	list:select(4)
end, { desc = "Harpoon: Go to file 4" })

vim.keymap.set("n", "<Leader>5", function()
	list:select(5)
end, { desc = "Harpoon: Go to file 5" })
