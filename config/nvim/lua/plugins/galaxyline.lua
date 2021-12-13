local gl = require('galaxyline')
-- local ccolors = require('colorbuddy.color').colors
local condition = require('galaxyline.condition')
local gls = gl.section
gl.short_line_list = {'packer'}

local colors = require("nightfox.colors").init()

--[[ local rgb = function(color)
  return color.to_rgb(color, color.H, color.S, color.L)
end

local colors = {
  mono_1 = rgb(ccolors.mono_1),
  mono_2 = rgb(ccolors.mono_2),
  mono_4 = rgb(ccolors.mono_4),
  visual_grey = rgb(ccolors.visual_grey),
  pmenu = rgb(ccolors.pmenu),
  syntax_bg = rgb(ccolors.syntax_bg),
  hue_1 = rgb(ccolors.hue_1), -- light green
  hue_2 = rgb(ccolors.hue_2), -- blue
  hue_3 = rgb(ccolors.hue_3), -- pink
  hue_4 = rgb(ccolors.hue_4), -- green
  hue_5 = rgb(ccolors.hue_5), -- red
  hue_6 = rgb(ccolors.hue_6), -- organge
  hue_6_2 = rgb(ccolors.hue_6_2), -- light organge
} ]]

local mode_color = {
  n = colors.blue,
  no = colors.blue,
  i = colors.green,
  v = colors.magenta,
  [''] = colors.magenta,
  V = colors.magenta,
  c = colors.orange
}

local function set_vi_mode_color (name)
  vim.api.nvim_command('hi Galaxy'..name..' guifg='..(mode_color[vim.fn.mode()] or colors.blue))
end

gls.left[1] = {
  RainbowRed = {
    provider = function()
      set_vi_mode_color('RainbowRed')
      return '▊ '
    end,
    highlight = {colors.blue, colors.bg_statusline}
    --  highlight = {colors.hue_1,colors.visual_grey}
  },
}
gls.left[2] = {
  ViMode = {
    provider = function()
      -- auto change color according the vim mode
      -- local mode_color = {
      --   n = colors.hue_4,
      --   no = colors.hue_4,
      --   i = colors.hue_2,
      --   v = colors.hue_3,
      --   [''] = colors.hue_3,
      --   V = colors.hue_3,
      --   c = colors.hue_1
      -- }
      set_vi_mode_color('ViMode')
      return require('galaxyline.provider_fileinfo').get_file_icon()..' '
    end,
    highlight = {colors.blue, colors.bg_statusline, 'bold'},
    --  highlight = {colors.hue_4,colors.visual_grey, 'bold'},
  },
}
gls.left[3] = {
  FileName = {
    provider = 'FileName',
    condition = condition.buffer_not_empty,
    separator = ' ',
    --  separator_highlight = {'NONE',colors.visual_grey},
    --  highlight = {colors.mono_1, colors.visual_grey, 'bold'}
    highlight = {colors.white, colors.bg_statusline, 'bold'},
    separator_highlight = {'NONE',colors.bg_statusline}
  }
}

gls.mid[1] = {
  ShowLspClient = {
    provider = 'GetLspClient',
    condition = condition.buffer_not_empty,
    icon = ' : ',
    separator = '  ',
    --  separator_highlight = {'NONE',colors.syntax_bg},
    --  highlight = {colors.hue_6_2, colors.syntax_bg}
    separator_highlight = {'NONE',colors.bg_statusline},
    highlight = {colors.white, colors.bg_statusline}
  }
}
gls.mid[2] = {
  DiagnosticError = {
    provider = 'DiagnosticError',
    icon = '  ',
    --  highlight = {colors.hue_5,colors.syntax_bg}
    highlight = {colors.red, colors.bg_statusline}
  }
}
gls.mid[3] = {
  DiagnosticWarn = {
    provider = 'DiagnosticWarn',
    icon = '  ',
    --  highlight = {colors.hue_6_2,colors.syntax_bg},
    highlight = {colors.yellow, colors.bg_statusline},
  }
}
gls.mid[4] = {
  DiagnosticHint = {
    provider = 'DiagnosticHint',
    icon = '  ',
    highlight = {colors.blue, colors.bg_statusline},
    --  highlight = {colors.hue_2,colors.syntax_bg},
  }
}

gls.mid[5] = {
  DiagnosticInfo = {
    provider = 'DiagnosticInfo',
    icon = '  ',
    --  highlight = {colors.hue_1,colors.visual_grey},
    highlight = {colors.blue, colors.bg_statusline},
  }
}

-- gls.right[1] = {
--   LspStatus = {
--     provider = function() return vim.inspect(require('lsp-status').messages()) end,
--  --     highlight = {colors.mono_1,colors.visual_grey,'bold'},
--   }
-- }

gls.right[2] = {
  LineInfo = {
    provider = 'LineColumn',
    separator = ' ',
    --  separator_highlight = {'NONE',colors.visual_grey},
    --  highlight = {colors.mono_1,colors.visual_grey,'bold'},
    separator_highlight = {'NONE',colors.bg_statusline},
    highlight = {colors.white,colors.bg_statusline,'bold'},
  }
}
gls.right[3] = {
  PerCent = {
    provider = 'LinePercent',
    --  highlight = {colors.mono_1,colors.visual_grey,'bold'},
    highlight = {colors.white,colors.bg_statusline,'bold'},
  }
}
gls.right[4] = {
  RainbowBlue = {
    provider = function()
      set_vi_mode_color('RainbowBlue')
      return ' ▊'
    end,
    --  highlight = {colors.hue_2,colors.visual_grey}
    highlight = {colors.blue, colors.bg_statusline},
  },
}

gls.short_line_left[1] = {
  RainbowGray = {
    provider = function() return '▊ ' end,
    --  highlight = {colors.mono_2, colors.pmenu}
    highlight = {colors.fg_alt, colors.bg_highlight}
  },
}
gls.short_line_left[2] = {
  SFileName = {
    provider =  'SFileName',
    condition = condition.buffer_not_empty,
    --  highlight = {colors.mono_2, colors.pmenu}
    highlight = {colors.fg_alt, colors.bg_highlight}
  }
}

gls.short_line_right[1] = {
  BufferIcon = {
    provider= 'BufferIcon',
    --  highlight = {colors.mono_2,colors.pmenu}
    highlight = {colors.fg_alt, colors.bg_highlight}
  }
}
gls.short_line_right[2] = {
  RainbowGray2 = {
    provider = function() return ' ▊' end,
    --  highlight = {colors.mono_2, colors.pmenu}
    highlight = {colors.fg_alt, colors.bg_highlight}
  },
}
