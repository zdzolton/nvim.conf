local M = {}

local ns = vim.api.nvim_create_namespace("review_hunk")

-- A tmux window option lets an external script find this instance's RPC socket.
function M.setup()
	if not vim.env.TMUX then
		return
	end
	vim.api.nvim_create_autocmd("VimEnter", {
		group = vim.api.nvim_create_augroup("review_register", { clear = true }),
		callback = function()
			vim.system({ "tmux", "set-option", "-w", "-t", vim.env.TMUX_PANE, "@nvim_server", vim.v.servername })
		end,
	})
end

function M.clear()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
	end
end

--- Open a file in a tab and highlight a line range.
--- Returns an empty string because it is called through `--remote-expr`.
---@param path string absolute file path
---@param first integer first line to highlight
---@param last integer last line to highlight
function M.open(path, first, last)
	M.clear()
	vim.cmd("tab drop " .. vim.fn.fnameescape(path))
	local buf = vim.api.nvim_get_current_buf()
	local count = vim.api.nvim_buf_line_count(buf)
	first = math.max(1, math.min(first, count))
	last = math.max(first, math.min(last, count))
	vim.api.nvim_win_set_cursor(0, { first, 0 })
	vim.cmd("normal! zz")
	for line = first, last do
		vim.api.nvim_buf_set_extmark(buf, ns, line - 1, 0, { line_hl_group = "Visual", priority = 200 })
	end
	vim.cmd("redraw")
	return ""
end

vim.api.nvim_create_user_command("ReviewClear", M.clear, {})

return M
