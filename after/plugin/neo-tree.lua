vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local ok, neo_tree = pcall(require, "neo-tree")
if not ok then
  vim.notify("neo-tree failed to load", vim.log.levels.ERROR)
  return
end

require("neo-tree").setup({})
