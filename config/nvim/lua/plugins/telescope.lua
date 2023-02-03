local ts_builtin = require("telescope.builtin")
local wk = require("which-key")

-- require('telescope').load_extension('fzf')
require("telescope").setup {
  pickers = {
    find_files = {
      find_command = { "fd", "--type", "f", "--strip-cwd-prefix", "--hidden"}
    },
  }
}

wk.register({
  ["<leader>f"] = { name = "[Telescope] +[F]ind" },
  ["<leader>r"] = { name = "[Telescope] +[R]uby" }
})

vim.keymap.set('n', "<Leader>ff", function() ts_builtin.find_files() end, { desc = "[F]iles"} )
vim.keymap.set('n', "<Leader>fF", function() ts_builtin.find_files({no_ignore = true}) end, { desc = "[F]iles with Ignored"} )
vim.keymap.set('n', "<Leader>f/", function() ts_builtin.current_buffer_fuzzy_find() end, { desc = "Buffer fuzzy find"} )
vim.keymap.set('n', "<Leader>fr", function() ts_builtin.oldfiles() end, { desc = "Recently opened files"} )
vim.keymap.set('n', "<Leader>fb", function() require "telescope".extensions.file_browser.file_browser() end, { desc = "Open [B]rowser"} )
vim.keymap.set('n', "<Leader>fc", function() ts_builtin.command_history() end, { desc = "[C]ommand Histroy"} )
-- vim.keymap.set('n', "<Leader>fr", function() ts_builtin.registers() end)
vim.keymap.set('n', "<Leader>fm", function() ts_builtin.keymaps() end, { desc = "Key[m]aps"} )
vim.keymap.set('n', "<Leader>fy", function() ts_builtin.filetypes() end, { desc = "Filet[y]pes"} )
vim.keymap.set('n', "<Leader>fg", function() ts_builtin.git_status() end, { desc = "[G]itStatus"} )
vim.keymap.set('n', "<Leader>fn", function() ts_builtin.reloader() end, { desc = "Reloader"} )
vim.keymap.set('n', "<Leader>ft", function() ts_builtin.treesitter() end, { desc = "[T]reesitter"} )
vim.keymap.set('n', "<Leader>fh", function() ts_builtin.help_tags() end, { desc = "[H]elp Tags"} )
-- vim.keymap.set('n', "<Leader>fd", function() ts_builtin.diagnostics() end, { desc = "[D]iagnostics"} )

-- neoclip
vim.keymap.set('n', "<Leader>fp", function() require('telescope').extensions.neoclip.default() end, { desc = "[P]aste registers"} )

-- ruby
vim.keymap.set('n', "<Leader>rm", function()
  local find_command = {'rg', '--files', '--hidden', '--follow', '--sortr=path', 'db/migrate'}
  ts_builtin.find_files({
    find_command = find_command
  })
end, { desc = "Migrations"} )
