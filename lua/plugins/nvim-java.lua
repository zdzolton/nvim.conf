return {
	"nvim-java/nvim-java",
	dependencies = {
		"nvim-java/lua-async-await",
		"nvim-java/nvim-java-core",
		"nvim-java/nvim-java-test",
		"nvim-java/nvim-java-dap",
		"MunifTanjim/nui.nvim",
		"neovim/nvim-lspconfig",
		"mfussenegger/nvim-dap",
	},
	config = function()
		-- Delay Java initialization to avoid errors for unrelated file types:
		-- https://github.com/nvim-java/nvim-java/issues/427
		-- https://github.com/nvim-java/nvim-java/issues/293
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "java",
			once = true,
			callback = function()
				-- used to enable autocompletion (assign to every lsp server config)
				local capabilities = require("blink.cmp").get_lsp_capabilities()
				-- enable snippet
				capabilities.textDocument.completion.completionItem.snippetSupport = true

				-- nvim-java handles JDTLS configuration automatically.
				-- It will call lspconfig.jdtls.setup() internally.
				require("java").setup({
					jdk = {
						auto_install = false,
					},
					lsp = {
						capabilities = capabilities,
					},
				})
			end,
		})
	end,
}
