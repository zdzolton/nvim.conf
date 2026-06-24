return {
	{
		"williamboman/mason.nvim",
		opts = {
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		},
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		opts = {
			-- list of lsp for mason to install
			-- Note: jdtls is NOT in this list - it's installed via mason-tool-installer
			-- to avoid mason-lspconfig from auto-configuring it
			ensure_installed = {
				"html",
				"cssls",
				"ts_ls",
				"eslint",
				"jsonls",
				"yamlls",
				"lua_ls",
				"pyright",
				"bashls",
				"intelephense",
			},
			-- Disable automatic server setup (we'll configure servers explicitly in lspconfig.lua)
			automatic_setup = false,
		},
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim" },
		opts = {
			-- list of formatter and linter for mason to install
			ensure_installed = {
				"jdtls", -- java language server (configured by nvim-jdtls, not mason-lspconfig)
				"java-debug-adapter", -- java debug adapter for nvim-dap
				"prettierd", -- prettierd formatter
				"stylua", -- lua formatter
				"isort", -- python formatter
				"black", -- python formatter
				"pylint", -- python linter
				"shfmt", -- sh formatter with bash support
				"beautysh", -- zsh formatter
				"vacuum", -- openapi linter (may require manual install if Mason fails)
				"apex-language-server", -- salesforce apex language server
				"sql-formatter", -- sql formatter
			},
		},
	},
}
