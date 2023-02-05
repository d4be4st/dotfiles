local gl = require('galaxyline')
-- local ccolors = require('colorbuddy.color').colors
local condition = require('galaxyline.condition')
local gls = gl.section
gl.short_line_list = {'packer'}

local nightfox_colors = require("nightfox.palette").load("nightfox")
local colors = {
  normal = nightfox_colors.blue.base,
  insert = nightfox_colors.green.base,
  visual = nightfox_colors.magenta.base,
  command = nightfox_colors.orange.base,
  warning = nightfox_colors.yellow.base,
  danger = nightfox_colors.red.base,
  fg_active = nightfox_colors.white.base,
  bg_active = nightfox_colors.bg0,
  -- fg_inactive = nightfox_colors.fg0,
  -- bg_inactive = nightfox_colors.bg4
}

-- local cat_colors = require("catppuccin.palettes").get_palette()
-- local colors = {
--   normal = cat_colors.blue,
--   insert = cat_colors.green,
--   visual = cat_colors.mauve,
--   command = cat_colors.orange,
--   warning = cat_colors.yellow,
--   danger = cat_colors.red,
--   fg_active = cat_colors.white,
--   bg_active = cat_colors.black1,
--   fg_inactive = cat_colors.gray0,
--   bg_inactive = cat_colors.black3
-- }

local mode_color = {
  n = colors.normal,
  no = colors.normal,
  i = colors.insert,
  v = colors.visual,
  [''] = colors.visual,
  V = colors.visual,
  c = colors.command
}

local function set_vi_mode_color (name)
  vim.api.nvim_command('hi Galaxy'..name..' guifg='..(mode_color[vim.fn.mode()] or colors.normal))
end

------------------------------------------- ACTIVE ----------------------
------------------------------------------- LEFT ------------------------
table.insert(gls.left, {
  RainbowRed = {
    provider = function()
      set_vi_mode_color('RainbowRed')
      return '▊ '
    end,
    highlight = {colors.normal, colors.bg_active}
  },
})
table.insert(gls.left, {
  ViMode = {
    provider = function()
      -- auto change color according the vim mode
      set_vi_mode_color('ViMode')
      return require('galaxyline.provider_fileinfo').get_file_icon()..' '
    end,
    highlight = {colors.normal, colors.bg_active, 'bold'},
  },
})
table.insert(gls.left, {
  FileName = {
    provider = 'FileName',
    condition = condition.buffer_not_empty,
    separator = ' ',
    highlight = {colors.fg_active, colors.bg_active, 'bold'},
    separator_highlight = {'NONE',colors.bg_active}
  }
})

------------------------------------------- MID -------------------------
table.insert(gls.mid, {
  ShowLspClient = {
    provider = 'GetLspClient',
    condition = condition.buffer_not_empty,
    icon = ' : ',
    separator = '  ',
    separator_highlight = {'NONE',colors.bg_active},
    highlight = {colors.fg_active, colors.bg_active}
  }
})
table.insert(gls.mid, {
  DiagnosticError = {
    provider = 'DiagnosticError',
    icon = '  ',
    highlight = {colors.danger, colors.bg_active}
  }
})
table.insert(gls.mid, {
  DiagnosticWarn = {
    provider = 'DiagnosticWarn',
    icon = '  ',
    highlight = {colors.warning, colors.bg_active},
  }
})
table.insert(gls.mid, {
  DiagnosticHint = {
    provider = 'DiagnosticHint',
    icon = '  ',
    highlight = {colors.normal, colors.bg_active},
  }
})
table.insert(gls.mid, {
  DiagnosticInfo = {
    provider = 'DiagnosticInfo',
    icon = '  ',
    highlight = {colors.normal, colors.bg_active},
  }
})

------------------------------------------- RIGHT ----------------------

table.insert(gls.right, {
  LineInfo = {
    provider = 'LineColumn',
    separator = ' ',
    separator_highlight = {'NONE',colors.bg_active},
    highlight = {colors.fg_active,colors.bg_active,'bold'},
  }
})
table.insert(gls.right, {
  PerCent = {
    provider = 'LinePercent',
    highlight = {colors.fg_active,colors.bg_active,'bold'},
  }
})
table.insert(gls.right, {
  Rainbownormal = {
    provider = function()
      set_vi_mode_color('Rainbownormal')
      return ' ▊'
    end,
    highlight = {colors.normal, colors.bg_active},
  },
})

-- ------------------------------------------- INACTIVE ----------------------
-- ------------------------------------------- LEFT ------------------------
-- table.insert(gls.short_line_left, {
--   RainbowGray = {
--     provider = function() return '▊ ' end,
--     highlight = {colors.fg_inactive, colors.bg_inactive}
--   },
-- })
-- table.insert(gls.short_line_left, {
--   SFileName = {
--     provider =  'SFileName',
--     condition = condition.buffer_not_empty,
--     highlight = {colors.fg_inactive, colors.bg_inactive}
--   }
-- })

-- ------------------------------------------- RIGHT ------------------------
-- table.insert(gls.short_line_right, {
--   BufferIcon = {
--     provider= 'BufferIcon',
--     highlight = {colors.fg_inactive, colors.bg_inactive}
--   }
-- })
-- table.insert(gls.short_line_right, {
--   RainbowGray2 = {
--     provider = function() return ' ▊' end,
--     highlight = {colors.fg_inactive, colors.bg_inactive}
--   },
-- })
