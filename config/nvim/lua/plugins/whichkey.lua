local wk = require('whichkey_setup')
wk.config({
    hide_statusline = false,
    default_keymap_settings = {
        silent=true,
        noremap=true,
    },
    default_mode = 'n',
})

local keymap = {
  l = {
    name = "+lsp",
    p = 'vim.lsp.diagnostic.goto_prev()',
    n = 'vim.lsp.diagnostic.goto_next()',
    l = 'vim.lsp.diagnostic.show_line_diagnostics()',
    r = 'vim.lsp.buf.rename()',
    h = 'vim.lsp.buf.hover()',
    D = 'vim.lsp.buf.declaration()',
    d = 'vim.lsp.buf.definition()',
    i = 'vim.lsp.buf.implementation()',
    s = 'vim.lsp.buf.signature_help()',
    t = 'vim.lsp.buf.type_definition()',
    R = 'vim.lsp.buf.references()',
    a = 'vim.lsp.buf.code_action()',
    f = 'vim.lsp.buf.formatting()'
  },
  f = {
    name = "+finder",
    f = 'find files',
    l = 'live grep',
    b = 'file browser',
    c = 'command history',
    m = 'keymaps',
    y = 'filetypes',
    g = 'git status',
    n = 'reloader'
  },
  r = {
    name = "+ruby",
    m = 'migrate files'
  }
}

wk.register_keymap('leader', keymap)
