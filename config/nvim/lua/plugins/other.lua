vim.g.highlightedyank_highlight_duration = 100
vim.g.splitjoin_ruby_hanging_args = 0
vim.g.splitjoin_ruby_curly_braces = 0

local gs = require('gitsigns')

vim.keymap.set('n', '<leader>ht', gs.toggle_current_line_blame)
vim.keymap.set('n', '<leader>hb', function()
  gs.blame_line{full=true}
end)

vim.keymap.set('n', '<leader>/', '<Plug>(leap-forward)', {silent = true})
vim.keymap.set('n', '<leader>?', '<Plug>(leap-backward)', {silent = true})
vim.keymap.set('n', '<leader>g/', '<Plug>(leap-cross-window)', {silent = true})
vim.keymap.set('x', '<leader>/', '<Plug>(leap-forward)', {silent = true})
vim.keymap.set('x', '<leader>?', '<Plug>(leap-backward)', {silent = true})
