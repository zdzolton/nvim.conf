local o = vim.o
local a = vim.api

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- Show line number
o.number = true

-- Disable unneeded backup
o.backup = false
o.writebackup = false

-- Save undo history
o.undofile = true

-- Improve search
o.ignorecase = true
o.smartcase = true
o.hlsearch = true

 -- Disable mouse mode
 o.mouse = ''

 -- DO NOT sync clipboard between OS and Neovim.
 --  See `:help 'clipboard'`
 o.clipboard = ''

 -- Disable break indent
 o.breakindent = false

-- Used for wrapping during text formatting
o.textwidth = 120

-- Show vertical ruler on column 120
vim.opt.colorcolumn = { '120' }

-- Don't automatically insert linebreaks
vim.opt.formatoptions:remove { 't' }

-- Configure how new splits should be opened
o.splitright = true
o.splitbelow = true

 -- Keep signcolumn on by default
 vim.wo.signcolumn = 'yes'

 -- Decrease update time
 o.updatetime = 250
 o.timeoutlen = 300

 -- Set completeopt to have a better completion experience
 o.completeopt = 'menuone,noselect'

 -- NOTE: You should make sure your terminal supports this
 o.termguicolors = true

 -- Set border for floating windows
 o.winborder = 'rounded'

 -- Use some fun characters when displaying invisibles
vim.opt.listchars = {
   eol = '↲',
   space = '⋅',
   trail = '•',
   tab = '⇄ ',
 }
vim.opt.list = false

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})
