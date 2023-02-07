local wk = require("which-key")
-- vim.g.splitjoin_ruby_hanging_args = 0
-- vim.g.splitjoin_ruby_curly_braces = 0



vim.keymap.set('n', '<leader>s', function() require('spectre').open() end, {desc = "Open [S]pectre"})
vim.keymap.set('n', '<leader>S', function() require('spectre').open_visual({select_word=true}) end, {desc = "Open [S]pectre with word"})
vim.keymap.set('v', '<leader>s', function() require('spectre').open_visual() end, {desc = "Open [S]pectre with selection"})

