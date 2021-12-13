local vimp = require("vimp")
local ts_builtin = require("telescope.builtin")

require('telescope').load_extension('fzf')

vimp.nnoremap("<Leader>ff", function() ts_builtin.find_files() end)
vimp.nnoremap("<Leader>fl", function() ts_builtin.current_buffer_fuzzy_find() end)
vimp.nnoremap("<Leader>fb", function() ts_builtin.file_browser() end)
vimp.nnoremap("<Leader>fc", function() ts_builtin.command_history() end)
-- vimp.nnoremap("<Leader>fr", function() ts_builtin.registers() end)
vimp.nnoremap("<Leader>fm", function() ts_builtin.keymaps() end)
vimp.nnoremap("<Leader>fy", function() ts_builtin.filetypes() end)
vimp.nnoremap("<Leader>fg", function() ts_builtin.git_status() end)
vimp.nnoremap("<Leader>fn", function() ts_builtin.reloader() end)
vimp.nnoremap("<Leader>ft", function() ts_builtin.treesitter() end)

-- neoclip
vimp.nnoremap("<Leader>fp", function() require('telescope').extensions.neoclip.default() end)

-- ruby
vimp.nnoremap("<Leader>rm", function()
  local find_command = {'rg', '--files', '--hidden', '--follow', '--sortr=path', 'db/migrate'}
  ts_builtin.find_files({
    find_command = find_command
  })
end)

local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
parser_config.crystal = {
  install_info = {
    url = "~/dev/misc/tree-sitter-crystal", -- local path or git repo
    files = {"src/parser.c"}
  }
}
