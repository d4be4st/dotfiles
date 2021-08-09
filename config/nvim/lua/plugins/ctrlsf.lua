vim.g.ctrlsf_ackprg = 'rg'
vimp.nmap('<leader>gg', '<Plug>CtrlSFPrompt')
vimp.nmap('<leader>gv', '<Plug>CtrlSFVwordExec')
vimp.nmap('<leader>gw', '<Plug>CtrlSFCCwordExec')
vimp.nnoremap('<leader>gs', function() require('spectre').open() end)
