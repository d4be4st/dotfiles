vim.g.mapleader = " " -- user <space> as leader
vim.opt.confirm = true -- confirm before exiting
vim.opt.hidden = true -- close hidden buffers
vim.opt.bufhidden = "hide"
vim.opt.scrolloff = 8 -- minimal number of screen lines above and below cursor
vim.opt.showmode = false -- remove --INSERT--
vim.opt.showtabline = 2 -- always show tabline
-- vim.opt.tabline = '%!v:lua.require\'luatab\'.tabline()'
vim.opt.splitbelow = true -- open new splits below
vim.opt.splitright = true -- open new splits on the right
vim.opt.switchbuf = "usetab,newtab" -- open buffer in new tab
vim.opt.ttimeoutlen = 50 -- timeout for key sequence to complete
vim.opt.undodir = "/Users/stef/.config/nvim/undodir" -- undo directory
vim.opt.updatetime = 100 -- default updatetime 4000ms is not good for async update
vim.opt.swapfile = false -- do not use swapfile
vim.opt.undofile = true -- enable undo file
vim.opt.undofile = true -- enable undo file
vim.opt.colorcolumn = "120" -- higlight column
vim.opt.list = true -- show tabs
vim.opt.number = true -- show numbers
vim.opt.signcolumn = "yes" -- show gutter
vim.opt.wrap = false -- disable wrap

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

vim.cmd('autocmd BufEnter * setlocal formatoptions-=o')
