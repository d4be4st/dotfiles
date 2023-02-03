-- vim.cmd("colorscheme nightfox")
-- vim.cmd.colorscheme "nightfox"

require("catppuccin").setup({
  highlight_overrides = {
    mocha = function(colors)
      return {
        TabLineSel = { fg = colors.surface0, bg = colors.mauve },
        TabLine = { fg = colors.overlay1, bg = colors.surface0 },
        TabLineFill = { bg = colors.surface0 }
      }
    end
  }
})

vim.cmd.colorscheme "catppuccin-mocha"
