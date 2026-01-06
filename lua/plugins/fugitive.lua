-- fugitive.vim - A Git wrapper so awesome, it should be illegal
-- https://github.com/tpope/vim-fugitive

return {
	"tpope/vim-fugitive",
	cmd = { "Git", "G", "Gdiffsplit", "Gvdiffsplit", "Gread", "Gwrite", "Ggrep", "GMove", "GDelete", "GBrowse" },
	keys = {
		{ "<leader>gb", "<cmd>Git blame<cr>", desc = "Git [B]lame" },
		{ "<leader>gs", "<cmd>Git<cr>", desc = "Git [S]tatus" },
		{ "<leader>gd", "<cmd>Gdiffsplit<cr>", desc = "Git [D]iff" },
	},
}
