return {
  "AckslD/nvim-neoclip.lua",
  lazy = true,
  name = 'neoclip',
  keys = {
    { '<leader>fp', function() require('telescope').extensions.neoclip.default() end, { desc = "[P]aste registers" }}
  },
  config = true
}
