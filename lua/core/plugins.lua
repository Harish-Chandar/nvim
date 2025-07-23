-- lua/core/plugins.lua

-- Bootstrap lazy.nvim if it's not already installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Plugin setup
require("lazy").setup({
	-- colorscheme
	{ "catppuccin/nvim", name = "catppuccin" },

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate"
	},

	-- Telescope
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = { "nvim-lua/plenary.nvim" },
	},

	-- Bufferline
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},

	-- Lualine
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},

	-- Neo-tree
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
			-- "3rd/image.nvim", -- Optional, if you ever want preview image support
		},
	},
	-- Comment
	{
		"numToStr/Comment.nvim",
		opts = {}
	},
	-- Harpoon
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	-- Git Merge Conflicts
	{
		'akinsho/git-conflict.nvim',
		version = "*",
		default_mappings = false,
		config = true
	},
	-- LSP
	{
		"neovim/nvim-lspconfig",
		tag = 'v1.0.0',
		config = function()
			require('lspconfig').pyright.setup{}  

			require'lspconfig'.ts_ls.setup{
				on_attach = function(client, bufnr)
					-- go to definition and rename
					vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', { noremap = true, silent = true })
					vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>gr', '<Cmd>lua vim.lsp.buf.rename()<CR>', { noremap = true, silent = true })

					-- autocompletes
					-- vim.api.nvim_buf_set_keymap(bufnr, 'i', '<Tab>', 'v:lua.vim.lsp.omnifunc', { expr = true, noremap = true })
				end,
				filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
				cmd = { "typescript-language-server", "--stdio" }
			}

			require('lspconfig').biome.setup{
				on_attach = your_on_attach_fn,
				filetypes = { "javascript", "javascriptreact", "javascript.jsx" },
				cmd = { "biome", "lsp-proxy" },
				root_dir = require('lspconfig.util').root_pattern(".biome.json", "biome.json", "package.json", ".git")
			}

			require('lspconfig').intelephense.setup{
				on_attach = on_attach,
				capabilities = capabilities,
				filetypes = { "php" },
				cmd = { "intelephense", "--stdio" },
				root_dir = require('lspconfig.util').root_pattern("composer.json", ".git"),
			}
		end
	},
	'hrsh7th/nvim-cmp',  -- nvim-cmp plugin
	'hrsh7th/cmp-nvim-lsp',  -- LSP completion source for nvim-cmp
	'hrsh7th/cmp-path',      -- path completions
	'hrsh7th/cmp-buffer',    -- buffer completions
	-- GitHub Copilot
	{
		"github/copilot.vim",
		version="1.51.0",
		branch="release",
	},
})

