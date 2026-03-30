return {
  "AckslD/nvim-neoclip.lua",
  config = function()
    require('neoclip').setup({
      keys = {
        telescope = {
          i = {
            select = '<cr>',
            paste = '<c-k>',
            paste_behind = '<c-j>',
            replay = '<c-q>',
            delete = '<c-d>',
            edit = '<c-e>',
            custom = {},
          },
        }
      }
    })
    vim.keymap.set('n', '<leader>fp', function() require('telescope').extensions.neoclip.default() end,
      { desc = "[P]aste registers" })
  end,
}
