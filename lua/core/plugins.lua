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
		lazy = false,
		branch = "master",
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

	--image
	{
		"3rd/image.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
	},

	-- Neo-tree
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
			"3rd/image.nvim", -- Optional, if you ever want preview image support
		},
	},

	-- Comment
	{
		"numToStr/Comment.nvim",
		opts = {},
	},
	{
		"Sargates/better-comments.nvim",
    	opts = {},
	},
	-- Harpoon
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	{
		'charludo/projectmgr.nvim',
		lazy = false, -- important!
	},
	-- Git signs
	{
		"lewis6991/gitsigns.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
			numhl = true,
			linehl = false,
			word_diff = false,
			current_line_blame = true,
			current_line_blame_opts = {
				delay = 1000,
			},
		},
	},
	-- Fugitive
	{
		"tpope/vim-fugitive",
	},
	-- Mini
	{
		"echasnovski/mini.nvim",
	},
	{
		"neovim/nvim-lspconfig",
		tag = 'v1.0.0',
		config = function()
		end
	},
	-- Mason (LSP installer) and mason-lspconfig bridge
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
	},
	{
		"mfussenegger/nvim-dap",
	},
	{ "nvim-neotest/nvim-nio" },
	{
		"jay-babu/mason-nvim-dap.nvim",
		event = "VeryLazy",
		dependencies = { "williamboman/mason.nvim", "mfussenegger/nvim-dap" },
		opts = {
			handlers = {},
		},
	},
	{
		"rcarriga/nvim-dap-ui",
		event = "VeryLazy",
		dependencies = { "mfussenegger/nvim-dap" },
		config = function()
			local dap, dapui = require("dap"), require("dapui")
			dapui.setup()
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end
		end,
	},
	'hrsh7th/nvim-cmp',  -- nvim-cmp plugin
	'hrsh7th/cmp-nvim-lsp',  -- LSP completion source for nvim-cmp
	'hrsh7th/cmp-path',      -- path completions
	'hrsh7th/cmp-buffer',    -- buffer completions
	-- GitHub Copilot
	{
		"github/copilot.vim",
		version="1.52.0",
		branch="release",
	},
	{
		"folke/sidekick.nvim",
		opts = {
			nes = {
				enabled = false,
			},
		},
		keys = {
			{
				"<c-.>",
				function()
					require("sidekick.cli").focus()
				end,
				desc = "Sidekick Focus",
				mode = { "n", "t", "i", "x" },
			},
			{
				"<leader>aa",
				function()
					require("sidekick.cli").toggle()
				end,
				desc = "Sidekick Toggle CLI",
			},
			{
				"<leader>as",
				function()
					require("sidekick.cli").select()
				end,
				-- Or to select only installed tools:
				-- require("sidekick.cli").select({ filter = { installed = true } })
				desc = "Select CLI",
			},
			{
				"<leader>ad",
				function()
					require("sidekick.cli").close()
				end,
				desc = "Detach a CLI Session",
			},
			{
				"<leader>at",
				function()
					require("sidekick.cli").send({ msg = "{this}" })
				end,
				mode = { "x", "n" },
				desc = "Send This",
			},
			{
				"<leader>af",
				function()
					require("sidekick.cli").send({ msg = "{file}" })
				end,
				desc = "Send File",
			},
			{
				"<leader>av",
				function()
					require("sidekick.cli").send({ msg = "{selection}" })
				end,
				mode = { "x" },
				desc = "Send Visual Selection",
			},
			{
				"<leader>ap",
				function()
					require("sidekick.cli").prompt()
				end,
				mode = { "n", "x" },
				desc = "Sidekick Select Prompt",
			},
			-- Example of a keybinding to open Copilot directly
			{
				"<leader>ac",
				function()
					require("sidekick.cli").toggle({ name = "copilot", focus = true })
				end,
				desc = "Sidekick Toggle Copilot",
			},
		},
	},
})

