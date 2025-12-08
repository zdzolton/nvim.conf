return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"williamboman/mason.nvim",
		"b0o/schemastore.nvim",
	},
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
					[x.ERROR] = " ",
					[x.WARN] = " ",
					[x.HINT] = "󰠠 ",
					[x.INFO] = " ",
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
	end,
}
