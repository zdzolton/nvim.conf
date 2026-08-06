return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"williamboman/mason.nvim",
		"b0o/schemastore.nvim",
	},
	init = function()
		-- jdtls: disable nvim-lspconfig's default config (we use nvim-jdtls instead)
		-- This must run in init (not config) to prevent nvim-lspconfig from creating
		-- a FileType autocmd for jdtls before we disable it
		vim.lsp.config("jdtls", {
			enabled = false,
			cmd = { "true" }, -- No-op command to prevent it from starting
			root_dir = function()
				return nil
			end, -- Never match any directory
		})
	end,
	config = function()
		local keymap = vim.keymap

		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(ev)
				-- buffer local mappings
				local opts = { buffer = ev.buf, silent = true }

				-- set keybinds
				-- show definition, references
				opts.desc = "Show LSP references"
				keymap.set("n", "gr", function()
					require("telescope.builtin").lsp_references()
				end, opts)

				-- go to declaration
				opts.desc = "Go to declaration"
				keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

				-- show lsp definitions
				opts.desc = "Show LSP definitions"
				keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)

				-- show lsp implementations
				opts.desc = "Show LSP implementations"
				keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

				-- -- show lsp type definitions
				-- opts.desc = "Show LSP type definitions"
				-- keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

				-- see available code actions
				opts.desc = "Show available code actions"
				keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

				-- smart rename
				opts.desc = "Smart rename"
				keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

				-- show diagnostics
				opts.desc = "Show buffer diagnostics"
				keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

				-- show diagnostics for line
				opts.desc = "Show line diagnostics"
				keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)

				-- jump to previous diagnostic in buffer
				opts.desc = "Go to previous diagnostic"
				keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

				-- jump to next diagnostic in buffer
				opts.desc = "Go to next diagnostic"
				keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

				-- show documentation for what is under cursor
				opts.desc = "Show documentation for what is under cursor"
				keymap.set("n", "K", vim.lsp.buf.hover, opts)

				-- mapping to restart lsp if necessary
				opts.desc = "Restart LSP"
				keymap.set("n", "<leader>rs", "<cmd>LspRestart<CR>", opts)

				-- show signature help automatically when typing ( or ,
				-- (disabled for bashls as it doesn't work well)
				local client = vim.lsp.get_client_by_id(ev.data.client_id)
				if client and client.name ~= "bashls" then
					vim.api.nvim_create_autocmd("TextChangedI", {
						buffer = ev.buf,
						callback = function()
							local line = vim.api.nvim_get_current_line()
							local col = vim.api.nvim_win_get_cursor(0)[2]
							-- Check both the character at cursor and after cursor
							-- because cursor position behavior can vary between LSP servers
							local char_at = col > 0 and line:sub(col, col) or ""
							local char_after = col < #line and line:sub(col + 1, col + 1) or ""

							if char_at == "(" or char_at == "," or char_after == "(" or char_after == "," then
								-- Use a longer delay for slower LSP servers like JDTLS
								-- Also schedule during an event loop tick to ensure LSP has processed the change
								vim.schedule(function()
									vim.defer_fn(function()
										vim.lsp.buf.signature_help()
									end, 150)
								end)
							end
						end,
					})
				end
			end,
		})

		-- used to enable autocompletion (assign to every lsp server config)
		local capabilities = require("blink.cmp").get_lsp_capabilities()
		-- enable snippet
		capabilities.textDocument.completion.completionItem.snippetSupport = true

		-- change diagnostic symbols in the sign column (gutter)
		local x = vim.diagnostic.severity
		vim.diagnostic.config({
			virtual_text = false,
			signs = {
				text = {
					[x.ERROR] = "‼",
					[x.WARN] = "⁉",
					[x.HINT] = "◎",
					[x.INFO] = "ℹ",
				},
			},
			underline = true,

			-- do the following for lsp diagnostics:
			-- 1. disable prefix (e.g. number)
			-- 2. sort from the highest severity
			-- 3. include the source where the warn/error come from
			float = { prefix = "", header = "", severity_sort = true, source = true },
		})

		-- configure signature help handler to not steal focus
		vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
			focusable = true,
			focus = false,
			focus_id = "signature_help",
		})

		-- lsp server config

		-- html: disable wrap line
		vim.lsp.config("html", {
			settings = {
				html = {
					format = {
						wrapLineLength = 0,
					},
				},
			},
		})
		-- css: ignore unknown rules
		vim.lsp.config("cssls", {
			settings = {
				css = {
					lint = {
						unknownAtRules = "ignore",
					},
				},
			},
		})
		-- json: validate using schema and pull from schemastore
		vim.lsp.config("jsonls", {
			settings = {
				json = {
					schemas = require("schemastore").json.schemas(),
					validate = { enable = true },
				},
			},
		})
		-- lua: recognize "vim" and "mp" global
		vim.lsp.config("lua_ls", {
			settings = {
				Lua = {
					diagnostics = {
						globals = { "vim", "mp" },
					},
				},
			},
		})
		-- bashls: also enable for zsh files
		vim.lsp.config("bashls", {
			filetypes = { "sh", "bash", "zsh" },
		})
		-- yamlls: validate using schemas from schemastore
		vim.lsp.config("yamlls", {
			filetypes = { "yaml", "yaml.openapi" },
			settings = {
				yaml = {
					schemaStore = {
						-- Disable built-in schemaStore to use schemastore.nvim
						enable = false,
						url = "",
					},
					-- Use schemastore with custom fileMatch patterns for OpenAPI
					-- Default to OpenAPI 3.0 schema (most common version)
					-- For OpenAPI 3.1 files, add this comment at the top:
					-- # yaml-language-server: $schema=https://spec.openapis.org/oas/3.1/schema/2025-09-15
					schemas = require("schemastore").yaml.schemas({
						replace = {
							-- Override openapi.json schema to match our file patterns
							["openapi.json"] = {
								name = "openapi.json",
								description = "OpenAPI 3.0 Specification",
								fileMatch = {
									"openapi.yaml",
									"openapi.yml",
									"openapi.json",
									"**/openapi/*.yaml",
									"**/openapi/*.yml",
									"**/openapi/*.json",
									"**/api-specs/*.yaml",
									"**/api-specs/*.yml",
									"**/api-specs/*.json",
									"**/api-specs/*/spec.yaml",
									"**/api-specs/*/spec.yml",
									"**/*-specs/spec.yaml",
									"**/*-specs/spec.yml",
									"swagger*.yaml",
									"swagger*.yml",
									"swagger*.json",
								},
								url = "https://spec.openapis.org/oas/3.0/schema/2024-10-18",
							},
						},
					}),
					validate = true,
					format = { enable = false }, -- Use prettierd via conform.nvim instead
					hover = true,
					completion = true,
				},
			},
		})
		-- vacuum: OpenAPI/Swagger linter and quality analysis
		vim.lsp.config("vacuum", {
			cmd = { "vacuum", "language-server" },
			filetypes = { "yaml.openapi", "json.openapi" },
			root_markers = { ".git" },
			single_file_support = true,
		})

		-- apex_ls: Salesforce Apex Language Server (installed via mason-tool-installer)
		vim.lsp.config("apex_ls", {
			apex_jar_path = vim.fn.stdpath("data") .. "/mason/share/apex-language-server/apex-jorje-lsp.jar",
			salesforce_project_root_markers = { "sfdx-project.json" },
		})

		-- Enable all LSP servers explicitly
		-- (since automatic_setup = false in mason-lspconfig)
		local servers = {
			"html",
			"cssls",
			"jsonls",
			"lua_ls",
			"ts_ls",
			"eslint",
			"yamlls",
			"pyright",
			"bashls",
			"vacuum",
			"intelephense",
			"apex_ls",
		}
		for _, server in ipairs(servers) do
			vim.lsp.enable(server)
		end
	end,
}
