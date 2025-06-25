local cmp = require'cmp'

cmp.setup({
    -- Use LSP for completion
    sources = {
        { name = 'nvim_lsp' },
		{ name = 'buffer' },
		{ name = 'path' },  
    },

    -- Configure completion keybindings
    mapping = {
        -- ['<Tab>'] = cmp.mapping.select_next_item(),
        -- ['<S-Tab>'] = cmp.mapping.select_prev_item(),

		 ['<Tab>'] = function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			else
				fallback()  -- Insert a real tab
			end
		end,

		['<S-Tab>'] = function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			else
				fallback()
			end
		end,

		['<Down>'] = cmp.mapping.select_next_item(),
        ['<Up>'] = cmp.mapping.select_prev_item(),

        ['<CR>'] = cmp.mapping.confirm({ select = true }),
    },
})

