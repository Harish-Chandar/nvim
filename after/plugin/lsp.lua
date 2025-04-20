-- Set up LSP diagnostics with colored boxes
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.handlers["textDocument/publishDiagnostics"], {
    -- Enable virtual text (message after the box)
    virtual_text = {
      -- Display the message as text (after the box)
      prefix = " ",  -- Symbol before the error message (could be empty or a symbol)
      spacing = 4,  -- Space between the box and the message
    },
    -- Show signs in the sign column
    signs = true,
    -- Show floating window when hovering
    float = {
      source = "always",  -- Show source (e.g., "tsserver") in the floating window
    },
  }
)

-- Configure diagnostic signs for errors, warnings, etc.
vim.fn.sign_define("LspDiagnosticsSignError", { text = "● ", texthl = "LspDiagnosticsDefaultError", linehl = "", numhl = "" })
vim.fn.sign_define("LspDiagnosticsSignWarning", { text = "● ", texthl = "LspDiagnosticsDefaultWarning", linehl = "", numhl = "" })
vim.fn.sign_define("LspDiagnosticsSignInformation", { text = "● ", texthl = "LspDiagnosticsDefaultInformation", linehl = "", numhl = "" })
vim.fn.sign_define("LspDiagnosticsSignHint", { text = "● ", texthl = "LspDiagnosticsDefaultHint", linehl = "", numhl = "" })

-- Set up diagnostic highlight groups to display colored boxes and text
-- Red box for errors, yellow for warnings, blue for info, etc.
vim.cmd [[
  highlight LspDiagnosticsDefaultError guibg=red guifg=white
  highlight LspDiagnosticsDefaultWarning guibg=yellow guifg=black
  highlight LspDiagnosticsDefaultInformation guibg=blue guifg=white
  highlight LspDiagnosticsDefaultHint guibg=blue guifg=white
]]

-- Add custom mappings for navigating diagnostics
vim.api.nvim_set_keymap('n', '[d', '<Cmd>lua vim.diagnostic.goto_prev()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', ']d', '<Cmd>lua vim.diagnostic.goto_next()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>d', '<Cmd>lua vim.diagnostic.open_float()<CR>', { noremap = true, silent = true })

