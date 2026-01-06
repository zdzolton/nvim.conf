-- Proper LSP setup for Lua development in Neovim
-- Automatically configures lua_ls to recognize plugin types
-- https://github.com/folke/lazydev.nvim

return {
	"folke/lazydev.nvim",
	ft = "lua",
	dependencies = {
		{ "Bilal2453/luvit-meta", lazy = true },
	},
	opts = {
		library = {
			-- Load luvit types when the `vim.uv` word is found
			{ path = "luvit-meta/library", words = { "vim%.uv" } },
		},
	},
}
