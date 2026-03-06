return {
	"mfussenegger/nvim-dap",
	ft = "java",
	dependencies = {
		{
			"rcarriga/nvim-dap-ui",
			dependencies = { "nvim-neotest/nvim-nio" },
		},
	},
	keys = {
		{
			"<leader>db",
			function()
				require("dap").toggle_breakpoint()
			end,
			desc = "Toggle breakpoint",
		},
		{
			"<leader>dB",
			function()
				require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end,
			desc = "Conditional breakpoint",
		},
		{
			"<leader>dc",
			function()
				require("dap").continue()
			end,
			desc = "Continue / start debugger",
		},
		{
			"<leader>do",
			function()
				require("dap").step_over()
			end,
			desc = "Step over",
		},
		{
			"<leader>di",
			function()
				require("dap").step_into()
			end,
			desc = "Step into",
		},
		{
			"<leader>dO",
			function()
				require("dap").step_out()
			end,
			desc = "Step out",
		},
		{
			"<leader>dt",
			function()
				require("dap").terminate()
				require("dapui").close()
			end,
			desc = "Terminate debugger",
		},
		{
			"<leader>du",
			function()
				require("dapui").toggle()
			end,
			desc = "Toggle DAP UI",
		},
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		dap.set_log_level("WARN")

		-- Override launch.json provider to use JDTLS root_dir instead of cwd.
		-- By default nvim-dap resolves .vscode/launch.json relative to cwd, but
		-- when Neovim is opened from a parent directory the launch.json won't be
		-- found. For java configs, merge with the auto-generated config so the
		-- full classpath (resolved at startup) is preserved.
		dap.providers.configs["dap.launch.json"] = function(bufnr)
			local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "jdtls" })
			local root_dir = clients[1] and clients[1].config.root_dir or vim.fn.getcwd()
			local ok, launch_configs = pcall(require("dap.ext.vscode").getconfigs, root_dir .. "/.vscode/launch.json")
			if not ok or not launch_configs or #launch_configs == 0 then
				return {}
			end
			local result = {}
			for _, lc in ipairs(launch_configs) do
				if lc.type == "java" then
					local merged = lc
					for _, auto in ipairs(dap.configurations.java or {}) do
						if auto.mainClass == lc.mainClass then
							-- auto-config has full classpath; launch.json has args/vmArgs
							merged = vim.tbl_extend("force", auto, lc)
							break
						end
					end
					table.insert(result, merged)
				else
					table.insert(result, lc)
				end
			end
			return result
		end

		dapui.setup()

		-- Auto-open UI when debugger starts, close when it ends
		dap.listeners.after.event_initialized["dapui_config"] = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated["dapui_config"] = function()
			dapui.close()
		end
		dap.listeners.before.event_exited["dapui_config"] = function()
			dapui.close()
		end
	end,
}
