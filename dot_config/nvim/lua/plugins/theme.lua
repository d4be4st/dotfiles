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
      local handle = io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null")
      local result = handle:read("*a")
      handle:close()

      if result:match("Dark") then
        vim.cmd.colorscheme "catppuccin-mocha"
      else
        vim.cmd.colorscheme "catppuccin-latte"
      end
    end
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons', 'catppuccin/nvim' },
    config = function()
      require('lualine').setup({
        options = {
          theme = vim.g.colors_name or 'auto',
          globalstatus = true,
          section_separators = { left = '', right = '' },
          component_separators = { left = '', right = '' },
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch', 'diff' },
          lualine_c = {
            { 'filename', symbols = { modified = '●' } },
            'diagnostics',
          },
          lualine_x = {
            {
              function()
                local clients = vim.lsp.get_clients({ bufnr = 0 })
                if next(clients) then return '󰅡 Lsp' end
                return ''
              end,
            },
            'searchcount',
            'filetype',
          },
          lualine_y = { 'progress' },
          lualine_z = { 'location' },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = {},
        },
      })
    end,
  },
}
