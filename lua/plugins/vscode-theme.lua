-- Theme inspired by VS Code
-- https://github.com/Mofiqul/vscode.nvim

return {
	"Mofiqul/vscode.nvim",
	priority = 1000,
	config = function()
		vim.cmd.colorscheme("vscode")
		vim.o.background = "light"
	end,
}
