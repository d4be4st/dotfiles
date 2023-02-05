return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      highlight_overrides = {
        mocha = function(colors)
          return {
            TabLineSel = { fg = colors.surface0, bg = colors.mauve },
            TabLine = { fg = colors.overlay1, bg = colors.surface0 },
            TabLineFill = { bg = colors.surface0 }
          }
        end
      }
    },
    init = function()
      vim.cmd.colorscheme "catppuccin-mocha"
    end
  },
  {
    'feline-nvim/feline.nvim',
    name = "feline",
    config = function()
      local ctp_feline = require('catppuccin.groups.integrations.feline')

      ctp_feline.setup({})

      require("feline").setup({
        components = ctp_feline.get(),
      })
    end
  },
}
