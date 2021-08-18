vim.g.mapleader = " " -- user <space> as leader
vim.o.confirm = true -- confirm before exiting
vim.o.hidden = false -- close hidden buffers
vim.o.scrolloff = 8 -- minimal number of screen lines above and below cursor
vim.o.showmode = false -- remove --INSERT--
vim.o.showtabline = 2 -- always show tabline
vim.o.tabline = '%!v:lua.require\'luatab\'.tabline()'
vim.o.splitbelow = true -- open new splits below
vim.o.splitright = true -- open new splits on the right
vim.o.switchbuf = "usetab,newtab" -- open buffer in new tab
vim.o.ttimeoutlen = 50 -- timeout for key sequence to complete
vim.o.undodir = "/Users/stef/.config/nvim/undodir" -- undo directory
vim.o.updatetime = 100 -- default updatetime 4000ms is not good for async update
vim.bo.swapfile = false -- do not use swapfile
vim.bo.undofile = true -- enable undo file
vim.o.undofile = true -- enable undo file
vim.wo.colorcolumn = "100" -- higlight column
vim.wo.list = true -- show tabs
vim.wo.number = true -- show numbers
vim.wo.signcolumn = "yes" -- show gutter
vim.wo.wrap = false -- disable wrap

-- search
vim.o.inccommand = "split" -- show search in preview
vim.o.gdefault = true -- make global replace default
vim.o.ignorecase = true -- ignorecase
vim.o.smartcase = true -- ignore ignorecase when upper case charaters present

-- Set tab to 2 spaces
local tabspaces = 2
vim.bo.tabstop = tabspaces
vim.o.tabstop = tabspaces
vim.bo.shiftwidth = tabspaces
vim.o.shiftwidth = tabspaces
vim.bo.expandtab = true
vim.o.expandtab = true

vim.cmd('autocmd BufEnter * setlocal formatoptions-=o')
