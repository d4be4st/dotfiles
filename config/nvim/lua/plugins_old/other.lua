local wk = require("which-key")
-- vim.g.splitjoin_ruby_hanging_args = 0
-- vim.g.splitjoin_ruby_curly_braces = 0

local gs = require('gitsigns')
wk.register({ ["<leader>g"] = { name = "+[g]it" } })
vim.keymap.set('n', '<leader>gp', gs.prev_hunk, {desc = "[P]revious Hunk"})
vim.keymap.set('n', '<leader>gn', gs.next_hunk, {desc = "[N]ext Hunk"})
vim.keymap.set('n', '<leader>gt', gs.toggle_current_line_blame, {desc = "[T]oggle current line blame"})
vim.keymap.set('n', '<leader>gT', gs.toggle_deleted, {desc = "[T]oggle deleted"})
vim.keymap.set('n', '<leader>gb', function() gs.blame_line{full=true} end, {desc = "[B]lame line"})
vim.keymap.set({'n', 'v'}, '<leader>gs', gs.stage_hunk, {desc = "[S]tage hunk"})
vim.keymap.set({'n', 'v'}, '<leader>gr', gs.reset_hunk, {desc = "[R]eset hunk"})
vim.keymap.set('n', '<leader>gS', gs.stage_buffer, {desc = "[S]tage buffer"})
vim.keymap.set('n', '<leader>gu', gs.undo_stage_hunk, {desc = "[U]ndo stage hunk"})
vim.keymap.set('n', '<leader>gR', gs.reset_buffer, {desc = "[R]eset buffer"})
vim.keymap.set('n', '<leader>gP', gs.preview_hunk, {desc = "[P]review hunk"})
vim.keymap.set('n', '<leader>gd', gs.diffthis, {desc = "[d]iff"})
vim.keymap.set('n', '<leader>gD', function() gs.diffthis('~') end, {desc = "[D]iff"})
vim.keymap.set('n', '<leader>gg', function() require("diffview").open() end, {desc = "[D]iff"})

--
vim.keymap.set('n', '<leader>/', '<Plug>(leap-forward)', {silent = true})
vim.keymap.set('n', '<leader>?', '<Plug>(leap-backward)', {silent = true})
vim.keymap.set('n', '<leader>=', '<Plug>(leap-cross-window)', {silent = true})
vim.keymap.set('x', '<leader>/', '<Plug>(leap-forward)', {silent = true})
vim.keymap.set('x', '<leader>?', '<Plug>(leap-backward)', {silent = true})


vim.keymap.set('n', '<leader>s', function() require('spectre').open() end, {desc = "Open [S]pectre"})
vim.keymap.set('n', '<leader>S', function() require('spectre').open_visual({select_word=true}) end, {desc = "Open [S]pectre with word"})
vim.keymap.set('v', '<leader>s', function() require('spectre').open_visual() end, {desc = "Open [S]pectre with selection"})

local genghis = require('genghis')
wk.register({ ["<leader>o"] = { name = "[o] +file" } })
vim.keymap.set('n', "<leader>os", genghis.duplicateFile, {desc = "[S]ave as new file" })
vim.keymap.set('n', "<leader>ox", genghis.chmodx, {desc = "Make current file e[x]ecutable" })
vim.keymap.set('n', "<leader>or", genghis.renameFile, {desc = "[R]ename file" })
vim.keymap.set('n', "<leader>om", genghis.moveAndRenameFile, {desc = "[M]ove file" })
vim.keymap.set('n', "<leader>od", genghis.trashFile, {desc = "[D]elete file" })
vim.keymap.set('n', "<leader>oc", genghis.createNewFile, {desc = "[C]reate file" })
vim.keymap.set("x", "<leader>on", genghis.moveSelectionToNewFile, {desc= "Move selection to [N]ew File"})


wk.register({ ["<leader>w"] = { name = "+[w]indow" } })
vim.keymap.set('n', "<leader>wm", require('windows.commands').maximize, {desc = "[M]aximize" })
vim.keymap.set('n', "<leader>we", require('windows.commands').equalize, {desc = "[E]qualize" })
vim.keymap.set('n', "<leader>wt", require('windows.autowidth').toggle, {desc = "[E]qualize" })
