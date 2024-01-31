vim.g.mapleader = " " -- user <space> as leader
vim.opt.termguicolors = true
vim.opt.confirm = true -- confirm before exiting
vim.opt.hidden = false -- close hidden buffers
vim.opt.laststatus = 3 -- global statusline
vim.opt.scrolloff = 8 -- minimal number of screen lines above and below cursor
vim.opt.showmode = false -- remove --INSERT--
vim.opt.showtabline = 2 -- always show tabline
vim.opt.splitbelow = true -- open new splits below
vim.opt.splitright = true -- open new splits on the right
vim.opt.switchbuf = "usetab,newtab" -- open buffer in new tab
vim.opt.ttimeoutlen = 50 -- timeout for key sequence to complete
vim.opt.undodir = "/Users/stef/.config/nvim/undodir" -- undo directory
vim.opt.updatetime = 100 -- default updatetime 4000ms is not good for async update
vim.opt.swapfile = false -- do not use swapfile
vim.opt.undofile = true -- enable undo file
vim.opt.undofile = true -- enable undo file
vim.opt.colorcolumn = "150" -- higlight column
vim.opt.list = true -- show tabs
vim.opt.number = true -- show numbers
vim.opt.signcolumn = "yes" -- show gutter
vim.opt.wrap = false -- disable wrap
vim.opt.mouse = "a"

-- search
vim.opt.inccommand = "split" -- show search in preview
vim.opt.gdefault = true -- make global replace default
vim.opt.ignorecase = true -- ignorecase
vim.opt.smartcase = true -- ignore ignorecase when upper case charaters present

-- Set tab to 2 spaces
local tabspaces = 2
vim.opt.tabstop = tabspaces
vim.opt.shiftwidth = tabspaces
vim.opt.expandtab = true

vim.cmd("autocmd BufEnter * setlocal formatoptions-=o")
-- vim.api.nvim_create_autocmd({"BufEnter"}, { pattern = {"*"}, callback = function ()
--   vim.opt.formatoptions = 0
-- end})

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})
