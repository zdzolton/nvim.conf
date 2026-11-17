local dir = vim.fn.expand(vim.env.TMUX_NVIM_CLAUDE_DIR or "~/code/tmux-nvim-claude") .. "/nvim"

-- Without this guard, lazy.nvim errors on every start when the repo is not cloned.
if not vim.uv.fs_stat(dir) then
	return {}
end

return { dir = dir, name = "tmux-review" }
