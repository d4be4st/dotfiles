-- Group.new('TabLine', c.mono_1, c.mono_4, no)
-- Group.new('TabLineFill', c.mono_3, c.syntax_bg, no)
-- Group.new('TabLineSel', c.pmenu, c.hue_1, no)
-- Group.new('StatusLine', c.mono_3, c.syntax_bg, no)

-- Group.new('DiffChange',  c.hue_6, c.syntax_bg, colorbuddy.underline)

-- Load the colorscheme
-- local nightfox = require('nightfox')
-- local colors = require("nightfox.colors").init()
-- nightfox.setup({
--   styles = {
--     comments = "italic", -- change style of comments to be italic
--     keywords = "bold", -- change style of keywords to be bold
--     -- functions = "italic,bold" -- styles can be a comma separated list
--   },
--   hlgroups = {
--     TabLine = { fg = colors.white },
--     TabLineFill = { bg = colors.bg_statusline },
--     TabLineSel = { bg = colors.white, fg = colors.bg_statusline }
--   }
-- })
-- nightfox.load()

-- vim.opt.termguicolors = true
local catppuccin = require("catppuccin")
catppuccin.setup({
  transparent_background = false,
  term_colors = false,
  styles = {
    comments = "italic",
    functions = "NONE",
    keywords = "bold",
    strings = "NONE",
    variables = "NONE",
  },
  integrations = {
    treesitter = true,
    native_lsp = {
      enabled = true,
      virtual_text = {
        errors = "italic",
        hints = "italic",
        warnings = "italic",
        information = "italic",
      },
      underlines = {
        errors = "underline",
        hints = "underline",
        warnings = "underline",
        information = "underline",
      },
    },
    lsp_trouble = false,
    cmp = true,
    lsp_saga = false,
    gitgutter = false,
    gitsigns = true,
    telescope = true,
    nvimtree = false,
    which_key = false,
    indent_blankline = false,
    dashboard = false,
    neogit = false,
    vim_sneak = false,
    fern = false,
    barbar = false,
    bufferline = false,
    markdown = false,
    lightspeed = false,
    ts_rainbow = false,
    hop = false,
    notify = false,
    telekasten = false,
  }
})
--     TabLine = { fg = colors.white },
--     TabLineFill = { bg = colors.bg_statusline },
--     TabLineSel = { bg = colors.white, fg = colors.bg_statusline }
local colors = require'catppuccin.api.colors'.get_colors() -- fetch colors with API
catppuccin.remap({
  TabLine = { fg = colors.maroon, bg = colors.black1 },
  TabLineFill = { fg = colors.black1, bg = colors.black1 },
  TabLineSel = { bg = colors.maroon, fg = colors.black1 },
  ColorColumn = { bg = colors.gray2 },
})

vim.cmd[[colorscheme catppuccin]]
