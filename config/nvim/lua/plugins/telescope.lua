local vimp = require("vimp")
local ts_builtin = require("telescope.builtin")

vimp.nnoremap("<Leader>ff", function()
  local find_command = {'rg', '--files', '--hidden', '--follow'}
  ts_builtin.find_files({
    find_command = find_command
  })
end)

vimp.nnoremap("<Leader>fl", function() ts_builtin.current_buffer_fuzzy_find() end)
vimp.nnoremap("<Leader>fb", function() ts_builtin.file_browser() end)
vimp.nnoremap("<Leader>fc", function() ts_builtin.command_history() end)
-- vimp.nnoremap("<Leader>fr", function() ts_builtin.registers() end)
vimp.nnoremap("<Leader>fm", function() ts_builtin.keymaps() end)
vimp.nnoremap("<Leader>fy", function() ts_builtin.filetypes() end)
vimp.nnoremap("<Leader>fg", function() ts_builtin.git_status() end)
vimp.nnoremap("<Leader>fn", function() ts_builtin.reloader() end)
vimp.nnoremap("<Leader>ft", function() ts_builtin.treesitter() end)

-- ruby
vimp.nnoremap("<Leader>rm", function()
  local find_command = {'rg', '--files', '--hidden', '--follow', '--sortr=path', 'db/migrate'}
  ts_builtin.find_files({
    find_command = find_command
  })
end)

-- require('telescope').setup {
--   extensions = {
--     fzf = {
--       override_generic_sorter = false, -- override the generic sorter
--       override_file_sorter = true,     -- override the file sorter
--       case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
--                                        -- the default case_mode is "smart_case"
--     }
--   }
-- }
-- -- To get fzf loaded and working with telescope, you need to call
-- -- load_extension, somewhere after setup function:
-- require('telescope').load_extension('fzf')
