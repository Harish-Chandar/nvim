local cmp = require'cmp'

vim.g.copilot_no_tab_map = true

-- Helper function to dismiss Copilot suggestion
local function dismiss_copilot()
    if vim.fn['copilot#GetDisplayedSuggestion']().text ~= "" then
        vim.fn['copilot#Dismiss']()
        return true
    end
    return false
end

cmp.setup({
    sources = {
        { name = 'nvim_lsp' },
        { name = 'buffer' },
        { name = 'path' },
        { name = 'copilot', option = {debounce = 100} },
    },

    mapping = {
        -- Dismiss mappings
        ['<Esc>'] = function(fallback)
            if not dismiss_copilot() then
                fallback()
            end
        end,
        ['<C-c>'] = function(fallback)
            if not dismiss_copilot() then
                fallback()
            end
        end,
        ['<C-[>'] = function(fallback)
            if not dismiss_copilot() then
                fallback()
            end
        end,

        ['<Tab>'] = function(fallback)
            ------------------------------------------------------------------
            -- 1. Try Copilot: if a suggestion is available, accept it
            ------------------------------------------------------------------
            local ok, copilot_keys = pcall(vim.fn['copilot#Accept'], '')
            if ok and copilot_keys ~= '' then
                vim.api.nvim_feedkeys(copilot_keys, 'i', true)
                return
            end

            ------------------------------------------------------------------
            -- 2. If cmp menu is visible, move to the next item
            ------------------------------------------------------------------
            if cmp.visible() then
                cmp.select_next_item()
            else
                fallback()
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
        ['<Up>']   = cmp.mapping.select_prev_item(),
        ['<CR>']   = cmp.mapping.confirm({ select = true }),
    },
})

-- local cmp = require'cmp'
--
-- cmp.setup({
--     -- Use LSP for completion
--     sources = {
--         { name = 'nvim_lsp' },
-- 		{ name = 'buffer' },
-- 		{ name = 'path' },  
--     },
--
--     -- Configure completion keybindings
--     mapping = {
--         -- ['<Tab>'] = cmp.mapping.select_next_item(),
--         -- ['<S-Tab>'] = cmp.mapping.select_prev_item(),
--
-- 		 ['<Tab>'] = function(fallback)
-- 			if cmp.visible() then
-- 				cmp.select_next_item()
		-- 	else
		-- 		fallback()  -- Insert a real tab
		-- 	end
		-- end,
		--
		-- ['<S-Tab>'] = function(fallback)
		-- 	if cmp.visible() then
		-- 		cmp.select_prev_item()
		-- 	else
		-- 		fallback()
		-- 	end
		-- end,
		--
		-- ['<Down>'] = cmp.mapping.select_next_item(),
  --       ['<Up>'] = cmp.mapping.select_prev_item(),
    --
    --     ['<CR>'] = cmp.mapping.confirm({ select = true }),
    -- },
-- })
-- local cmp = require'cmp'
--
-- -- Disable Copilot's default <Tab> mapping so ours wins
-- vim.g.copilot_no_tab_map = true   -- keep this near your Copilot setup
-- 
-- cmp.setup({
--     sources = {
--         { name = 'nvim_lsp' },
--         { name = 'buffer' },
--         { name = 'path' },
-- 		{ name = 'copilot', option = {debounce = 100} },
--     },
-- 
--     mapping = {
--         ['<Tab>'] = function(fallback)
--             ------------------------------------------------------------------
--             -- 1. Try Copilot: if a suggestion is available, accept it
--             ------------------------------------------------------------------
--             local ok, copilot_keys = pcall(vim.fn['copilot#Accept'], '')
--             --   ok  : pcall didn’t error (function exists)
--             --   copilot_keys : string with the expansion (empty when none)
-- 
--             if ok and copilot_keys ~= '' then
--                 -- Feed the accepted text to Neovim
--                 vim.api.nvim_feedkeys(copilot_keys, 'i', true)
--                 return
--             end
-- 
--             ------------------------------------------------------------------
--             -- 2. If cmp menu is visible, move to the next item
--             ------------------------------------------------------------------
--             if cmp.visible() then
--                 cmp.select_next_item()
--             else
--                 ----------------------------------------------------------------
--                 -- 3. Otherwise just insert a tab (your editor is set to 4‑space
--                 --    tabs already, so it respects that setting)
--                 ----------------------------------------------------------------
--                 fallback()
--             end
--         end,
-- 
--         ['<S-Tab>'] = function(fallback)
--             if cmp.visible() then
--                 cmp.select_prev_item()
--             else
--                 fallback()
--             end
--         end,
-- 
--         ['<Down>'] = cmp.mapping.select_next_item(),
--         ['<Up>']   = cmp.mapping.select_prev_item(),
--         ['<CR>']   = cmp.mapping.confirm({ select = true }),
--     },
-- })
