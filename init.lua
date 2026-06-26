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

vim.api.nvim_create_autocmd("BufWinEnter", {
    pattern = "*.html",
    callback = function()
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        if #lines == 1 and lines[1] == "" then
            
            local home = os.getenv("HOME")
            local template_path = home .. "/.config/nvim/html.template"
            
            vim.cmd("0r " .. template_path)
            
            vim.cmd("$delete")
        end
    end
})
