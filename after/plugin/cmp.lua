local cmp = require'cmp'

cmp.setup({
    -- Use LSP for completion
    sources = {
        { name = 'nvim_lsp' },
    },

    -- Configure completion keybindings
    mapping = {
        ['<Tab>'] = cmp.mapping.select_next_item(),
        ['<S-Tab>'] = cmp.mapping.select_prev_item(),

		['<Down>'] = cmp.mapping.select_next_item(),
        ['<Up>'] = cmp.mapping.select_prev_item(),

        ['<CR>'] = cmp.mapping.confirm({ select = true }),
    },
})

