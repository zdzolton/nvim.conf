local function setup_jdtls()
	local jdtls = require("jdtls")

	-- Get blink.cmp capabilities
	local capabilities = require("blink.cmp").get_lsp_capabilities()
	capabilities.textDocument.completion.completionItem.snippetSupport = true

	-- Find mason's jdtls installation path
	-- Use vim.fn.stdpath("data") to get the path to mason packages
	local jdtls_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"

	-- Check if jdtls directory exists
	if vim.fn.isdirectory(jdtls_path) == 0 then
		vim.notify("jdtls is not installed. Run :MasonInstall jdtls", vim.log.levels.ERROR)
		return
	end

	-- Determine OS-specific config
	local os_config = "linux"
	if vim.fn.has("mac") == 1 then
		os_config = "mac"
	elseif vim.fn.has("win32") == 1 then
		os_config = "win"
	end

	-- Workspace directory - separate workspace per project
	local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
	local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

	-- Build bundles for java-debug
	local bundles = {}
	local debug_jar = vim.fn.glob(
		vim.fn.stdpath("data")
			.. "/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar"
	)
	if debug_jar ~= "" then
		vim.list_extend(bundles, vim.split(debug_jar, "\n"))
	end

	-- JDTLS configuration
	local config = {
		cmd = {
			"java",
			"-Declipse.application=org.eclipse.jdt.ls.core.id1",
			"-Dosgi.bundles.defaultStartLevel=4",
			"-Declipse.product=org.eclipse.jdt.ls.core.product",
			"-Dlog.protocol=true",
			"-Dlog.level=ALL",
			"-Xmx1g",
			"--add-modules=ALL-SYSTEM",
			"--add-opens",
			"java.base/java.util=ALL-UNNAMED",
			"--add-opens",
			"java.base/java.lang=ALL-UNNAMED",
			"-jar",
			vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar"),
			"-configuration",
			jdtls_path .. "/config_" .. os_config,
			"-data",
			workspace_dir,
		},
		root_dir = jdtls.setup.find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),
		capabilities = capabilities,
		on_attach = function(_, _)
			jdtls.setup_dap({ hotcodereplace = "auto" })
			require("jdtls.dap").setup_dap_main_class_configs()
		end,
		settings = {
			java = {
				signatureHelp = { enabled = true },
				contentProvider = { preferred = "fernflower" },
				completion = {
					favoriteStaticMembers = {
						"org.junit.jupiter.api.Assertions.*",
						"org.junit.Assert.*",
						"org.mockito.Mockito.*",
					},
				},
				sources = {
					organizeImports = {
						starThreshold = 9999,
						staticStarThreshold = 9999,
					},
				},
				codeGeneration = {
					toString = {
						template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
					},
					useBlocks = true,
				},
			},
		},
		init_options = {
			bundles = bundles,
		},
	}

	-- Start or attach to JDTLS
	jdtls.start_or_attach(config)
end

return {
	"mfussenegger/nvim-jdtls",
	ft = "java",
	dependencies = {
		"neovim/nvim-lspconfig",
	},
	config = function()
		-- Delay JDTLS initialization to avoid errors for unrelated file types
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "java",
			callback = setup_jdtls,
		})
	end,
}
