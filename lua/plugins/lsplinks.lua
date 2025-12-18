-- lsplinks.nvim
-- https://github.com/icholy/lsplinks.nvim
-- LSP document links (enables gx for $ref navigation in OpenAPI)

return {
	"icholy/lsplinks.nvim",
	config = function()
		local lsplinks = require("lsplinks")
		lsplinks.setup()
		-- Override gx to use LSP document links
		vim.keymap.set("n", "gx", lsplinks.gx, { desc = "Follow LSP document link" })
	end,
}
