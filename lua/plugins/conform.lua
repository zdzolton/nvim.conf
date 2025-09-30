-- Autoformat
-- https://github.com/stevearc/conform.nvim

return {
	"stevearc/conform.nvim",

	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>f",
			function()
				require("conform").format({ async = true, lsp_format = "fallback" })
			end,
			mode = "",
			desc = "[F]ormat buffer",
		},
	},
	-- This will provide type hinting with LuaLS
	---@module "conform"
	---@type conform.setupOpts
	opts = {
		-- log_level = vim.log.levels.DEBUG,
		notify_on_error = false,
		format_on_save = nil, -- Do NOT format when saving a buffer
		formatters = {
			isort = {
				prepend_args = { "-l", "1000000", "--wl", "0", "--sl" },
			},
			macchiato = {
				command = "black-macchiato",
				args = function()
					return { "-l", tostring(vim.o.textwidth) }
				end,
			},
			tidy_xml = {
				command = "tidy",
				args = function()
					return { "-quiet", "-xml", "--wrap", "120", "--indent", "yes", "--indent-attributes", "yes" }
				end,
			},
		},
		formatters_by_ft = {
			lua = { "stylua" },
			java = { "google-java-format" },
			python = { "macchiato", "isort" },
			xml = { "tidy_xml" },
			-- Conform can also run multiple formatters sequentially
			-- python = { "isort", "black" },
			--
			-- You can use 'stop_after_first' to run the first available formatter from the list
			-- javascript = { "prettierd", "prettier", stop_after_first = true },
		},
	},
}
