vim.o.completeopt = "menuone,noselect"
vim.o.shortmess = vim.o.shortmess..'c'

require "compe".setup {
    enabled = true,
    documentation = true,
    source = {
      buffer = true,
      path = true,
      luasnip = true,
      nvim_lsp = true,
      nvim_lua = true,
    }
}

vim.cmd([[inoremap <silent><expr> <C-k> compe#confirm({ 'keys': '<CR>', 'mode': 'n', 'select': v:true })]])
