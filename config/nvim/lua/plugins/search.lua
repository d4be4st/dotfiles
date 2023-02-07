return {
  {
    'windwp/nvim-spectre',
    keys = {
      {'<leader>s', function() require('spectre').open() end, 'n', desc = "Open [S]pectre"},
      {'<leader>S', function() require('spectre').open_visual({select_word=true}) end, desc = "Open [S]pectre with word"},
      {'<leader>s', function() require('spectre').open_visual() end, 'v', desc = "Open [S]pectre with selection"},
    },
    config = function ()
      require('spectre').setup()
    end
  },

  {
    "ggandor/leap.nvim",
    keys = {
      { '<leader>/', function() require('leap').leap {} end, { 'n', 'v' }, silent = true, desc = "Leap forward" },
      { '<leader>?', function() require('leap').leap { backward = true } end, 'n', 'v',
        { silent = true, desc = "Leap backwards" } },
      { '<leader>=', function()
        require('leap').leap {
          target_windows = require 'leap.util'.get_enterable_windows()
        }
      end, { 'n', 'x', 'o' }, silent = true, desc = "Leap cross window" },
    }
  },
}
