-- Blazing fast status line
-- https://github.com/nvim-lualine/lualine.nvim

return {
  'nvim-lualine/lualine.nvim',
  -- See `:help lualine.txt`
  opts = {
    options = {
      icons_enabled = false,
      theme = 'vscode',
      component_separators = '|',
      section_separators = '',
    },
  },
}
