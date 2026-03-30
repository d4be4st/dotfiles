return {
  {
    'saghen/blink.cmp',
    version = '*',
    dependencies = { 'L3MON4D3/LuaSnip', 'giuxtaposition/blink-cmp-copilot' },
    opts = {
      cmdline = {
        sources = { 'cmdline', 'path' },
      },
      keymap = {
        preset = 'default',
        ['<C-s>'] = { 'show', 'fallback' },
        ['<C-k>'] = { 'select_and_accept', 'fallback' },
        ['<C-e>'] = { 'hide', 'fallback' },
        ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
      },
      snippets = { preset = 'luasnip' },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer', 'copilot' },
        providers = {
          snippets = {
            score_offset = 5,
          },
          copilot = {
            name = 'copilot',
            module = 'blink-cmp-copilot',
            score_offset = 100,
            async = true,
          },
        },
      },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'mono',
      },
    },
  },

  {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      local ls = require('luasnip')
      vim.keymap.set('i', '<S-C-k>', function() ls.jump(-1) end, { silent = true })
      require("luasnip/loaders/from_vscode").lazy_load()
    end
  },
}
