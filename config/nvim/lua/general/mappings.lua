local wk = require("which-key")

-- Allow misspellings
vim.cmd('cnoreabbrev qw wq')
vim.cmd("cnoreabbrev Wq wq")
vim.cmd('cnoreabbrev WQ wq')
vim.cmd('cnoreabbrev W w')
vim.cmd('cnoreabbrev Q q')
vim.cmd('cnoreabbrev Qa qa')
vim.cmd('cnoreabbrev Xa xa')
vim.cmd('cnoreabbrev t tabe')
vim.cmd('cnoreabbrev qt tabclose')
vim.cmd('cnoreabbrev Qt tabclose')

-- remove highlights
vim.keymap.set('n', '<leader><leader>', function()
  vim.cmd('nohlsearch')
end, {silent = true, desc = "Clear search highlights"})

-- undo
vim.keymap.set('n', 'U', '<C-r>', { desc = "Redo" })
-- misstyped :q
vim.keymap.set('n', 'q:', '', { desc = "Misstyped :q"})

-- Saner command line history
vim.keymap.set('c', '<c-n>', '<down>', { desc = "Command -- history [n]ext" })
vim.keymap.set('c', '<c-p>', '<up>', {desc = "Command -- history [p]revious" })

-- Don't lose selection when shifting sidewards
vim.keymap.set('x', '<', '<gv', {desc = "Saner indent left"})
vim.keymap.set('x', '>', '>gv', {desc = "Saner indent right"})

-- Easier window switching
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = "Switch to pane left"})
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = "Switch to pane down"})
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = "Switch to pane up"})
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = "Switch to pane right"})
vim.keymap.set('n', '<C-c>', '<C-w>c', { desc = "Close window"})
vim.keymap.set('i', '<C-c>', '<Esc><C-w>c', { desc = "Close window"})

-- Remap H and L (top, bottom of screen to left and right end of line)
vim.keymap.set('n', 'H', '^', { desc = "Go to the beginning of the line"})
vim.keymap.set('n', 'L', '$', { desc = "Go to the end of the line"})
vim.keymap.set('v', 'H', '^', { desc = "Select to the beginning of the line"})
vim.keymap.set('v', 'L', 'g_', { desc = "Select to the end of the line"})

-- More logical Y (default was alias for yy)
vim.keymap.set('n', 'Y', 'y$', { desc = "[Y]ank whole line"})

-- Yank and paste from clipboard
wk.add({ { "<leader>y", group = "yank" }, })
vim.keymap.set('v', '<leader>y', '"+y', { desc = "Yank selection to clipboard"})
vim.keymap.set('n', '<leader>Y', '"+Y', { desc = "Yank whole line to clipboard"})
vim.keymap.set('v', '<leader>Y', '"+Y', { desc = "Yank whole line to clipboard"})
vim.keymap.set('n', '<leader>yy', '"+yy', { desc = "Yank whole line to clipboard"})
vim.keymap.set('n', '<leader>p', '"+p', { desc = "Paste from clipboard"})
vim.keymap.set('v', '<leader>p', '"+p', { desc = "Paste from to selection"})

-- Reselect pasted text
vim.keymap.set('n', 'gp', '`[v`]', { desc = "Reselect pasted text"})

-- Keep the cursor in place while joining lines
vim.keymap.set('n', 'J', 'mzJ`z', { desc = "[J]oin lines"})

-- [S]plit line (sister to [J]oin lines) S is covered by cc.
vim.keymap.set('n', 'S', 'mzi<CR><ESC>`z', { desc = "[S]plit line"})

-- Select all text
vim.keymap.set('n', 'vA', 'ggVG', { desc = "Select all text"})

-- Switch between tabs
vim.keymap.set('n', '<leader>1', '1gt')
vim.keymap.set('n', '<leader>2', '2gt')
vim.keymap.set('n', '<leader>3', '3gt')
vim.keymap.set('n', '<leader>4', '4gt')
vim.keymap.set('n', '<leader>5', '5gt')
vim.keymap.set('n', '<leader>6', '6gt')
vim.keymap.set('n', '<leader>7', '7gt')
vim.keymap.set('n', '<leader>8', '8gt')
vim.keymap.set('n', '<leader>9', '9gt')

-- Intelligent windows resizing using ctrl + arrow keys
vim.keymap.set('n', '<S-Up>', '   :resize +2<CR>', { silent = true, desc = "Resize up"})
vim.keymap.set('n', '<S-Down>', ' :resize -2<CR>', { silent = true, desc = "Resize down"})
vim.keymap.set('n', '<S-Left>', ' :vertical resize +2<CR>', { silent = true, desc = "Resize left"})
vim.keymap.set('n', '<S-Right>', ':vertical resize -2<CR>', { silent = true, desc = "Resize right"})
-- Creating splits with empty buffers in all directions
wk.add({ { "<leader>n", group = "new panes" }, })
vim.keymap.set('n', '<leader>nh', ':leftabove  vnew<CR>', { desc = "Create new pane above"})
vim.keymap.set('n', '<leader>nl', ':rightbelow vnew<CR>', { desc = "Create new pane below"})
vim.keymap.set('n', '<leader>nk', ':leftabove  new<CR>', { desc = "Create new pane left"})
vim.keymap.set('n', '<leader>nj', ':rightbelow new<CR>', { desc = "Create new pane right"})
vim.keymap.set('n', '<leader>nt', ':tabe<CR>', { desc = "Create new tab"})

-- Command Emacs home
vim.keymap.set('c', '<C-a>', '<home>', { desc = "Command -- goto beginning"})

-- Terminal mode
-- <ESC> exits terminal mode (does NOT send Esc to the process — safe for most cases).
-- If a process like Claude Code would be cancelled by Esc, use <C-q> instead
-- (also mapped per-terminal in lua/plugins/terminal.lua via TermOpen autocmd).
vim.keymap.set('t', '<ESC>', [[<C-\><C-n>]], { desc = "Return to normal mode" })
vim.keymap.set('t', '<C-q>',  [[<C-\><C-n>]], { desc = "Return to normal mode (no Esc sent)" })

-- Navigate away from any terminal (including Claude Code) with <C-hjkl>.
-- Global so it works regardless of which plugin opened the terminal.
-- NOTE: <C-h> (backspace) and <C-l> (clear screen) are intercepted — use
-- <Backspace> and `reset` instead inside the terminal.
vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], { desc = "Terminal: go left" })
-- vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], { desc = "Terminal: go down" })
vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], { desc = "Terminal: go up" })
vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], { desc = "Terminal: go right" })
