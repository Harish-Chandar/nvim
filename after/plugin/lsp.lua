-- after/plugin/lsp.lua

-- nvim-cmp setup for LSP snippets/completion
local cmp_nvim_lsp = require("cmp_nvim_lsp")
local capabilities = vim.lsp.protocol.make_client_capabilities()
-- augments the capabilities object with nvim-cmp's defaults:
capabilities = cmp_nvim_lsp.default_capabilities(capabilities)

local on_attach = function(client, bufnr)
	local bufopts = { noremap=true, silent=true, buffer=bufnr }
	local telescope_builtin = require("telescope.builtin")

	-- go to definition
	vim.keymap.set("n", "gd", telescope_builtin.lsp_definitions, bufopts)
	-- hover to show signature / docs / “definition”
	vim.keymap.set("n", "vd", vim.lsp.buf.hover, bufopts)
	-- rename symbol
	vim.keymap.set("n", "vrn", vim.lsp.buf.rename, bufopts)
	-- find references
	vim.keymap.set("n", "vrr", telescope_builtin.lsp_references, bufopts)
	-- document symbols (functions, variables, classes, etc.)
	vim.keymap.set("n", "<leader>df", telescope_builtin.lsp_document_symbols, bufopts)

end

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
vim.lsp.handlers["textDocument/publishDiagnostics"], {
	virtual_text = { prefix = " ", spacing = 4 },
	signs      = true,
	float      = { source = "always" },
}
)

vim.api.nvim_set_keymap('n', '[d', '<Cmd>lua vim.diagnostic.goto_prev()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', ']d', '<Cmd>lua vim.diagnostic.goto_next()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>d', '<Cmd>lua vim.diagnostic.open_float()<CR>', { noremap = true, silent = true })

local lspconfig = require("lspconfig")

local has_mason, mason = pcall(require, "mason")
local has_mason_lsp, mason_lspconfig = pcall(require, "mason-lspconfig")
if has_mason and has_mason_lsp then
	mason.setup()
	local ok, err = pcall(function()
		mason_lspconfig.setup()
	end)

	local did_handlers = false
	if type(mason_lspconfig.setup_handlers) == "function" then
		did_handlers = true
		mason_lspconfig.setup_handlers({
		-- default handler (for most servers)
		function(server_name)
			require("lspconfig")[server_name].setup({
				on_attach = on_attach,
				capabilities = capabilities,
			})
		end,

		-- Custom handler for tsserver to include JS filetypes and root detection
		["tsserver"] = function()
			lspconfig.tsserver.setup{
				on_attach = on_attach,
				capabilities = capabilities,
				filetypes = { "typescript", "typescriptreact", "typescript.tsx", "javascript", "javascriptreact", "javascript.jsx" },
				root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", ".git"),
			}
		end,

		-- Custom handler for intelephense to preserve your root_dir rule
		["intelephense"] = function()
			lspconfig.intelephense.setup{
				on_attach = on_attach,
				capabilities = capabilities,
				root_dir = lspconfig.util.root_pattern("composer.json", ".git", ".gitignore"),
			}
		end,
		-- Custom handler for clangd (C/C++) with recommended flags
		["clangd"] = function()
			lspconfig.clangd.setup{
				on_attach = on_attach,
				capabilities = capabilities,
				cmd = { "clangd", "--background-index", "--clang-tidy" },
				filetypes = { "c", "cpp", "objc", "objcpp" },
				root_dir = lspconfig.util.root_pattern("compile_commands.json", ".clangd", ".git"),
			}
		end,
	})
	end

	if not did_handlers then
		lspconfig.pyright.setup{
			on_attach = on_attach,
			capabilities = capabilities,
		}

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

		lspconfig.biome.setup{
			on_attach = on_attach,
			capabilities = capabilities,
			root_dir = lspconfig.util.root_pattern(".biome.json", "package.json", ".git"),
		}

		lspconfig.intelephense.setup{
			on_attach = on_attach,
			capabilities = capabilities,
			root_dir = lspconfig.util.root_pattern("composer.json", ".git", ".gitignore"),
		}

		-- Fallback clangd setup
		lspconfig.clangd.setup{
			on_attach = on_attach,
			capabilities = capabilities,
			cmd = { "clangd", "--background-index", "--clang-tidy" },
			filetypes = { "c", "cpp", "objc", "objcpp" },
			root_dir = lspconfig.util.root_pattern("compile_commands.json", ".clangd", ".git"),
		}
	end
else
	-- Fallback: if Mason isn't available, set up servers manually as before
	lspconfig.pyright.setup{
		on_attach = on_attach,
		capabilities = capabilities,
	}

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

	lspconfig.biome.setup{
		on_attach = on_attach,
		capabilities = capabilities,
		root_dir = lspconfig.util.root_pattern(".biome.json", "package.json", ".git"),
	}

	lspconfig.intelephense.setup{
		on_attach = on_attach,
		capabilities = capabilities,
		root_dir = lspconfig.util.root_pattern("composer.json", ".git", ".gitignore"),
	}
end
