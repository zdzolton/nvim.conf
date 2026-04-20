-- Shows the context of currently visible buffer contents
-- https://github.com/nvim-treesitter/nvim-treesitter-context

return {
	"nvim-treesitter/nvim-treesitter-context",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	event = "BufReadPost",
	enabled = true,
	opts = {
		max_lines = "15%",
		mode = "topline",
		multiline_threshold = 1,
		trim_scope = "inner",
	},
}
