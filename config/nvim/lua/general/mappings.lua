local vimp = require('vimp')

-- Allow misspellings
vim.cmd('cnoreabbrev qw wq')
vim.cmd('cnoreabbrev Wq wq')
vim.cmd('cnoreabbrev WQ wq')
vim.cmd('cnoreabbrev W w')
vim.cmd('cnoreabbrev Q q')
vim.cmd('cnoreabbrev Qa qa')
vim.cmd('cnoreabbrev Xa xa')
vim.cmd('cnoreabbrev t tabe')
vim.cmd('cnoreabbrev qt tabclose')

-- remove highlights
vimp.nnoremap({'silent'}, '<leader><leader>', function()
  vim.cmd('nohlsearch')
end)

-- undo
vimp.nnoremap('U', '<C-r>')
-- misspelled :q
vimp.nnoremap('q:', '')

-- Saner command line history
vimp.cnoremap('<c-n>', '<down>')
vimp.cnoremap('<c-p>', '<up>')

-- Don't lose selection when shifting sidewards
vimp.xnoremap('<', '<gv')
vimp.xnoremap('>', '>gv')

-- Easier window switching
vimp.nnoremap('<C-h>', '<C-w>h')
vimp.nnoremap('<C-j>', '<C-w>j')
vimp.nnoremap('<C-k>', '<C-w>k')
vimp.nnoremap('<C-l>', '<C-w>l')

-- Remap H and L (top, bottom of screen to left and right end of line)
vimp.nnoremap('H', '^')
vimp.nnoremap('L', '$')
vimp.vnoremap('H', '^')
vimp.vnoremap('L', 'g_')

-- More logical Y (default was alias for yy)
vimp.nnoremap('Y', 'y$')

-- Yank and paste from clipboard
vimp.vnoremap('<leader>y', '"+y')
vimp.nnoremap('<leader>Y', '"+Y')
vimp.vnoremap('<leader>Y', '"+Y')
vimp.nnoremap('<leader>yy', '"+yy')
vimp.nnoremap('<leader>p', '"+p')
vimp.vnoremap('<leader>p', '"+p')

-- Delete and change to black hole
vimp.nnoremap('<leader>d', '"_dd')
vimp.vnoremap('<leader>d', '"_d')

-- Keep the cursor in place while joining lines
vimp.nnoremap('J', 'mzJ`z')

-- [S]plit line (sister to [J]oin lines) S is covered by cc.
vimp.nnoremap('S', 'mzi<CR><ESC>`z')

-- Select all text
vimp.nnoremap('vA', 'ggVG')

-- Switch between tabs
-- set Ctrl-n to S-Fn in iterm prefs
-- vimp.nmap('<S-F1>', '1gt')
-- vimp.nmap('<S-F2>', '2gt')
-- vimp.nmap('<S-F3>', '3gt')
-- vimp.nmap('<S-F4>', '4gt')
-- vimp.nmap('<S-F5>', '5gt')
-- vimp.nmap('<S-F6>', '6gt')
-- vimp.nmap('<S-F7>', '7gt')
-- vimp.nmap('<S-F8>', '8gt')
-- vimp.nmap('<S-F9>', '9gt')
vimp.nmap('<F13>', '1gt')
vimp.nmap('<F14>', '2gt')
vimp.nmap('<F15>', '3gt')
vimp.nmap('<F16>', '4gt')
vimp.nmap('<F17>', '5gt')
vimp.nmap('<F18>', '6gt')
vimp.nmap('<F19>', '7gt')
vimp.nmap('<F20>', '8gt')
vimp.nmap('<F21>', '9gt')

-- Intelligent windows resizing using ctrl + arrow keys
vimp.nnoremap('<S-Up>', '   :resize +2<CR>')
vimp.nnoremap('<S-Down>', ' :resize -2<CR>')
vimp.nnoremap('<S-Left>', ' :vertical resize +2<CR>')
vimp.nnoremap('<S-Right>', ':vertical resize -2<CR>')
-- Zoom one pane
vimp.nnoremap('<leader>-', '<C-W><C-|><C-W><C-_>')
-- Restore panes
vimp.nnoremap('<leader>=', '<C-w><C-=>')

-- Creating splits withyempty buffers in all directions
vimp.nnoremap('<Leader>nh', ':leftabove  vnew<CR>')
vimp.nnoremap('<Leader>nl', ':rightbelow vnew<CR>')
vimp.nnoremap('<Leader>nk', ':leftabove  new<CR>')
vimp.nnoremap('<Leader>nj', ':rightbelow new<CR>')
vimp.nnoremap('<Leader>nt', ':tabe<CR>')

vimp.cnoremap('<C-a>', '<home>')

-- Current file things
vimp.nnoremap('<leader>os', function()
  local path = vim.fn.expand('%')
  vim.api.nvim_input(":sav "..path)
end)
vimp.nnoremap('<leader>ok', function()
  local path = vim.fn.expand('%:h')
  vim.api.nvim_input(":Mkdir! "..path)
end)
vimp.nnoremap('<leader>or', function()
  local path = vim.fn.expand('%:t')
  vim.api.nvim_input(":Rename "..path)
end)
vimp.nnoremap('<leader>om', function()
  local path = vim.fn.expand('%')
  vim.api.nvim_input(":Move "..path)
end)
vimp.nnoremap('<leader>od', function()
  vim.api.nvim_input(":Delete")
end)

-- Copy dir/file/line to clipboard
vimp.nnoremap('<leader>sl', function()
  vim.api.nvim_command('let @*=expand("%") . ":" . line(".")')
end)
vimp.nnoremap('<leader>sf', function()
  vim.api.nvim_command('let @*=expand("%")')
end)
