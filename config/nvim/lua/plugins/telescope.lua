local ts_builtin = require("telescope.builtin")

-- require('telescope').load_extension('fzf')
require("telescope").setup {
  pickers = {
    find_files = {
      find_command = { "fd", "--type", "f", "--strip-cwd-prefix", "--hidden"}
    },
  }
}

vim.keymap.set('n', "<Leader>ff", function() ts_builtin.find_files() end)
vim.keymap.set('n', "<Leader>fl", function() ts_builtin.current_buffer_fuzzy_find() end)
vim.keymap.set('n', "<Leader>fb", function() require "telescope".extensions.file_browser.file_browser() end)
vim.keymap.set('n', "<Leader>fc", function() ts_builtin.command_history() end)
-- vim.keymap.set('n', "<Leader>fr", function() ts_builtin.registers() end)
vim.keymap.set('n', "<Leader>fm", function() ts_builtin.keymaps() end)
vim.keymap.set('n', "<Leader>fy", function() ts_builtin.filetypes() end)
vim.keymap.set('n', "<Leader>fg", function() ts_builtin.git_status() end)
vim.keymap.set('n', "<Leader>fn", function() ts_builtin.reloader() end)
vim.keymap.set('n', "<Leader>ft", function() ts_builtin.treesitter() end)

-- neoclip
vim.keymap.set('n', "<Leader>fp", function() require('telescope').extensions.neoclip.default() end)

-- ruby
vim.keymap.set('n', "<Leader>rm", function()
  local find_command = {'rg', '--files', '--hidden', '--follow', '--sortr=path', 'db/migrate'}
  ts_builtin.find_files({
    find_command = find_command
  })
end)
