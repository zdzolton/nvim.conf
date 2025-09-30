-- Adds git related signs to the gutter, as well as utilities for managing changes
-- https://github.com/lewis6991/gitsigns.nvim

-- See `:help gitsigns` to understand what the configuration keys do
return {
	"lewis6991/gitsigns.nvim",
	event = "BufReadPre", -- Load the plugin before reading a buffer
	config = function()
		require("gitsigns").setup({
			-- Your Gitsigns configuration options here
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
			signcolumn = true, -- Show the sign column
			numhl = true, -- Highlight line numbers
			linehl = false, -- Highlight the entire line
			word_diff = false, -- Enable word-level diffs
			watch_gitdir = {
				follow_files = true,
			},
			auto_attach = true,
			current_line_blame = false, -- Display blame info on current line
			-- More options can be found in :help gitsigns-setup
		})
	end,
}
