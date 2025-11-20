# Claude Code Guidelines for Neovim Configuration

This document provides guidelines for Claude Code when editing Lua files in this Neovim configuration repository.

## Code Formatting

After making any edits to Lua files in this repository, you must format them using `stylua`. This project uses `stylua` as its Lua formatter, which is installed via Mason (`WhoIsSethDaniel/mason-tool-installer.nvim`).

### Formatting Command

Run this command after editing any `.lua` files:

```bash
~/.local/share/nvim/mason/bin/stylua <file_path>
```

### Example Workflow

1. Make edits to a Lua file (e.g., using the Edit or Write tool)
2. Format the file: `~/.local/share/nvim/mason/bin/stylua lua/plugins/lsp/lspconfig.lua`
3. Verify changes with `git diff` to ensure formatting is correct

## Project Structure

- `init.lua` - Main entry point
- `lua/main/` - Core configuration (settings, keymaps, plugins)
- `lua/plugins/` - Plugin-specific configuration files
- `lua/plugins/lsp/` - LSP-related plugin configurations

## LSP Configuration

The main LSP configuration is in `lua/plugins/lsp/lspconfig.lua`. When editing:

- Preserve existing keymaps and autocmds
- Maintain the diagnostic configuration structure
- Keep tabs for indentation (handled by stylua)
- Format with stylua after changes

## Additional Notes

- This config uses lazy.nvim as the plugin manager
- Mason is used for LSP server and tool installation
- Blink.cmp is used for completion capabilities
