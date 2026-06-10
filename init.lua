print("Welcome, Harish!")
require("core.mappings")
require("core.options")

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("core.plugins")

require("core.stats")
require("core.contributors")

vim.opt.termguicolors = true
require("bufferline").setup{}
