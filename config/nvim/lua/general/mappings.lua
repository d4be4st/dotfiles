vim.g.mapleader = " " -- user <space> as leader

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
vim.keymap.set('n', '<leader><leader>', function()
  vim.cmd('nohlsearch')
end, {silent = true})

-- undo
vim.keymap.set('n', 'U', '<C-r>')
-- misspelled :q
vim.keymap.set('n', 'q:', '')

-- Saner command line history
vim.keymap.set('c', '<c-n>', '<down>')
vim.keymap.set('c', '<c-p>', '<up>')

-- Don't lose selection when shifting sidewards
vim.keymap.set('x', '<', '<gv')
vim.keymap.set('x', '>', '>gv')

-- Easier window switching
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')

-- Remap H and L (top, bottom of screen to left and right end of line)
vim.keymap.set('n', 'H', '^')
vim.keymap.set('n', 'L', '$')
vim.keymap.set('v', 'H', '^')
vim.keymap.set('v', 'L', 'g_')

-- More logical Y (default was alias for yy)
vim.keymap.set('n', 'Y', 'y$')

-- Yank and paste from clipboard
vim.keymap.set('v', '<leader>y', '"+y')
vim.keymap.set('n', '<leader>Y', '"+Y')
vim.keymap.set('v', '<leader>Y', '"+Y')
vim.keymap.set('n', '<leader>yy', '"+yy')
vim.keymap.set('n', '<leader>p', '"+p')
vim.keymap.set('v', '<leader>p', '"+p')

-- Delete and change to black hole
vim.keymap.set('n', '<leader>d', '"_dd')
vim.keymap.set('v', '<leader>d', '"_d')

-- Keep the cursor in place while joining lines
vim.keymap.set('n', 'J', 'mzJ`z')

-- [S]plit line (sister to [J]oin lines) S is covered by cc.
vim.keymap.set('n', 'S', 'mzi<CR><ESC>`z')

-- Select all text
vim.keymap.set('n', 'vA', 'ggVG')

-- Switch between tabs
-- set Ctrl-n to S-Fn in iterm prefs
-- vim.keymap.set('n', '<S-F1>', '1gt')
-- vim.keymap.set('n', '<S-F2>', '2gt')
-- vim.keymap.set('n', '<S-F3>', '3gt')
-- vim.keymap.set('n', '<S-F4>', '4gt')
-- vim.keymap.set('n', '<S-F5>', '5gt')
-- vim.keymap.set('n', '<S-F6>', '6gt')
-- vim.keymap.set('n', '<S-F7>', '7gt')
-- vim.keymap.set('n', '<S-F8>', '8gt')
-- vim.keymap.set('n', '<S-F9>', '9gt')
vim.keymap.set('n', '<F13>', '1gt')
vim.keymap.set('n', '<F14>', '2gt')
vim.keymap.set('n', '<F15>', '3gt')
vim.keymap.set('n', '<F16>', '4gt')
vim.keymap.set('n', '<F17>', '5gt')
vim.keymap.set('n', '<F18>', '6gt')
vim.keymap.set('n', '<F19>', '7gt')
vim.keymap.set('n', '<F20>', '8gt')
vim.keymap.set('n', '<F21>', '9gt')

-- Intelligent windows resizing using ctrl + arrow keys
vim.keymap.set('n', '<S-Up>', '   :resize +2<CR>')
vim.keymap.set('n', '<S-Down>', ' :resize -2<CR>')
vim.keymap.set('n', '<S-Left>', ' :vertical resize +2<CR>')
vim.keymap.set('n', '<S-Right>', ':vertical resize -2<CR>')
-- Zoom one pane
vim.keymap.set('n', '<leader>-', '<C-W><C-|><C-W><C-_>')
-- Restore panes
vim.keymap.set('n', '<leader>=', '<C-w><C-=>')

-- Creating splits withyempty buffers in all directions
vim.keymap.set('n', '<Leader>nh', ':leftabove  vnew<CR>')
vim.keymap.set('n', '<Leader>nl', ':rightbelow vnew<CR>')
vim.keymap.set('n', '<Leader>nk', ':leftabove  new<CR>')
vim.keymap.set('n', '<Leader>nj', ':rightbelow new<CR>')
vim.keymap.set('n', '<Leader>nt', ':tabe<CR>')

vim.keymap.set('c', '<C-a>', '<home>')

-- Current file things
vim.keymap.set('n', '<leader>os', function()
  local path = vim.fn.expand('%')
  vim.api.nvim_input(":sav "..path)
end)
vim.keymap.set('n', '<leader>ok', function()
  local path = vim.fn.expand('%:h')
  vim.api.nvim_input(":Mkdir! "..path)
end)
vim.keymap.set('n', '<leader>or', function()
  local path = vim.fn.expand('%:t')
  vim.api.nvim_input(":Rename "..path)
end)
vim.keymap.set('n', '<leader>om', function()
  local path = vim.fn.expand('%')
  vim.api.nvim_input(":Move "..path)
end)
vim.keymap.set('n', '<leader>od', function()
  vim.api.nvim_input(":Delete")
end)

-- Copy dir/file/line to clipboard
vim.keymap.set('n', '<leader>sl', function()
  vim.api.nvim_command('let @*=expand("%") . ":" . line(".")')
end)
vim.keymap.set('n', '<leader>sf', function()
  vim.api.nvim_command('let @*=expand("%")')
end)
