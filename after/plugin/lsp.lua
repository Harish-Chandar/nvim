-- -- Set up LSP diagnostics with colored boxes
-- vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
--   vim.lsp.handlers["textDocument/publishDiagnostics"], {
--     -- Enable virtual text (message after the box)
--     virtual_text = {
--       -- Display the message as text (after the box)
--       prefix = " ",  -- Symbol before the error message 
--       spacing = 4,  -- Space between the box and the message
--     },
--     -- Show signs in the sign column
--     signs = true,
--     -- Show floating window when hovering
--     float = {
--       source = "always",  -- Show source (e.g., "tsserver") in the floating window
--     },
--   }
-- )
--
-- -- Configure diagnostic signs for errors, warnings, etc.
-- vim.fn.sign_define("LspDiagnosticsSignError", { text = "● ", texthl = "LspDiagnosticsDefaultError", linehl = "", numhl = "" })
-- vim.fn.sign_define("LspDiagnosticsSignWarning", { text = "● ", texthl = "LspDiagnosticsDefaultWarning", linehl = "", numhl = "" })
-- vim.fn.sign_define("LspDiagnosticsSignInformation", { text = "● ", texthl = "LspDiagnosticsDefaultInformation", linehl = "", numhl = "" })
-- vim.fn.sign_define("LspDiagnosticsSignHint", { text = "● ", texthl = "LspDiagnosticsDefaultHint", linehl = "", numhl = "" })
--
-- -- Set up diagnostic highlight groups to display colored boxes and text
-- -- Red box for errors, yellow for warnings, blue for info, etc.
-- vim.cmd [[
--   highlight LspDiagnosticsDefaultError guibg=red guifg=white
--   highlight LspDiagnosticsDefaultWarning guibg=yellow guifg=black
--   highlight LspDiagnosticsDefaultInformation guibg=blue guifg=white
--   highlight LspDiagnosticsDefaultHint guibg=blue guifg=white
-- ]]
--
-- -- Add custom mappings for navigating diagnostics
-- vim.api.nvim_set_keymap('n', '[d', '<Cmd>lua vim.diagnostic.goto_prev()<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', ']d', '<Cmd>lua vim.diagnostic.goto_next()<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<Leader>d', '<Cmd>lua vim.diagnostic.open_float()<CR>', { noremap = true, silent = true })
--

-- after/plugin/lsp.lua

-- nvim-cmp setup for LSP snippets/completion
local cmp_nvim_lsp = require("cmp_nvim_lsp")
local capabilities = vim.lsp.protocol.make_client_capabilities()
-- augments the capabilities object with nvim-cmp's defaults:
capabilities = cmp_nvim_lsp.default_capabilities(capabilities)

-- this on_attach will be called for *every* LSP server you set up:
local on_attach = function(client, bufnr)
	local bufopts = { noremap=true, silent=true, buffer=bufnr }

	-- go to definition
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
	-- hover to show signature / docs / “definition”
	vim.keymap.set("n", "vd", vim.lsp.buf.hover, bufopts)
	-- rename symbol
	vim.keymap.set("n", "vrn", vim.lsp.buf.rename, bufopts)
	-- find references
	vim.keymap.set("n", "vrr", vim.lsp.buf.references, bufopts)

	-- (you can of course add more here: e.g. vca for code action, etc.)
end

-- diagnostics configuration (you already have this; just ensure it stays loaded)
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
vim.lsp.handlers["textDocument/publishDiagnostics"], {
	virtual_text = { prefix = " ", spacing = 4 },
	signs      = true,
	float      = { source = "always" },
}
)

-- Add custom mappings for navigating diagnostics
vim.api.nvim_set_keymap('n', '[d', '<Cmd>lua vim.diagnostic.goto_prev()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', ']d', '<Cmd>lua vim.diagnostic.goto_next()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>d', '<Cmd>lua vim.diagnostic.open_float()<CR>', { noremap = true, silent = true })

-- Finally, set up each server with this shared on_attach+capabilities
local lspconfig = require("lspconfig")

-- Python
lspconfig.pyright.setup{
	on_attach = on_attach,
	capabilities = capabilities,
}

-- TypeScript
local configs = require("lspconfig.configs")
if not configs["ts-ls"] then
	configs["ts-ls"] = {
		default_config = {
			cmd = { "typescript-language-server", "--stdio" },
			filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
			root_dir = require("lspconfig.util").root_pattern("tsconfig.json", "package.json", ".git"),
			single_file_support = true,
		}
	}
end

lspconfig["ts-ls"].setup{
	on_attach = on_attach,
	capabilities = capabilities,
	cmd = { "typescript-language-server", "--stdio" },
	filetypes = { "typescript", "typescriptreact", "typescript.tsx", "javascript", "javascriptreact", "javascript.jsx" },
	root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", ".git"),
}

-- Biome (JavaScript)
lspconfig.biome.setup{
	on_attach = on_attach,
	capabilities = capabilities,
	root_dir = lspconfig.util.root_pattern(".biome.json", "package.json", ".git"),
}

-- PHP
lspconfig.intelephense.setup{
	on_attach = on_attach,
	capabilities = capabilities,
	root_dir = lspconfig.util.root_pattern("composer.json", ".git"),
}
