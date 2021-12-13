-- local colorbuddy = require('colorbuddy')
-- -- colorbuddy.colorscheme('onebuddy', 'light')
-- colorbuddy.colorscheme('onebuddy')
-- local Group = colorbuddy.Group
-- local c = colorbuddy.colors
-- local no = colorbuddy.NONE

-- Group.new('TabLine', c.mono_1, c.mono_4, no)
-- Group.new('TabLineFill', c.mono_3, c.syntax_bg, no)
-- Group.new('TabLineSel', c.pmenu, c.hue_1, no)
-- Group.new('StatusLine', c.mono_3, c.syntax_bg, no)

-- Group.new('DiffChange',  c.hue_6, c.syntax_bg, colorbuddy.underline)

-- Load the colorscheme
local nightfox = require('nightfox')
local colors = require("nightfox.colors").init()
nightfox.setup({
  styles = {
    comments = "italic", -- change style of comments to be italic
    keywords = "bold", -- change style of keywords to be bold
    -- functions = "italic,bold" -- styles can be a comma separated list
  },
  hlgroups = {
    TabLine = { fg = colors.white },
    TabLineFill = { bg = colors.bg_statusline },
    TabLineSel = { bg = colors.white, fg = colors.bg_statusline }
  }
})
nightfox.load()
