vim.g.ctrlsf_ackprg = 'rg'
vim.keymap.set('n', '<leader>gg', '<Plug>CtrlSFPrompt')
vim.keymap.set('n', '<leader>gv', '<Plug>CtrlSFVwordExec')
vim.keymap.set('n', '<leader>gw', '<Plug>CtrlSFCCwordExec')
vim.keymap.set('n', '<leader>gs', function() require('spectre').open() end)
