local cmp = require'cmp'

-- Disable Copilot's default <Tab> mapping so ours wins
vim.g.copilot_no_tab_map = true

-- Helper function to dismiss Copilot suggestion
local function dismiss_copilot()
    -- Safety check: ensure copilot function exists before calling
    if vim.fn.exists("*copilot#GetDisplayedSuggestion") == 1 then
        local suggestion = vim.fn['copilot#GetDisplayedSuggestion']()
        if suggestion and suggestion.text ~= "" then
            vim.fn['copilot#Dismiss']()
            return true
        end
    end
    return false
end

cmp.setup({
    -- Explicitly define performance and behavior to avoid race conditions
    performance = {
        debounce = 60,
        throttle = 30,
        fetching_timeout = 500,
    },

    sources = cmp.config.sources({
        { name = 'nvim_lsp', priority = 1000 },
        { name = 'copilot', priority = 750, option = { debounce = 100 } },
    }, {
        { name = 'path' },
        { name = 'buffer' },
    }),

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
            if vim.fn.exists("*copilot#Accept") == 1 then
                local ok, copilot_keys = pcall(vim.fn['copilot#Accept'], '')
                if ok and copilot_keys ~= '' then
                    vim.api.nvim_feedkeys(copilot_keys, 'i', true)
                    return
                end
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

