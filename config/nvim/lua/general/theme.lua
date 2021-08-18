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

-- Example in lua
-- vim.g.nightfox_style = "palefox"
-- vim.g.nightfox_color_delimiter = "red"
vim.g.nightfox_italic_comments = 1

-- Load the colorscheme
require('nightfox').set()
