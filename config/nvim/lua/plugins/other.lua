require("lspkind").init(
  {
    with_text = true
  }
)

require('gitsigns').setup()
require('colorizer').setup()
require('neoscroll').setup()
require("octo").setup()

require('kommentary.config').configure_language("default", {
    prefer_single_line_comments = true,
})

vim.g.highlightedyank_highlight_duration = 100
vim.g.splitjoin_ruby_hanging_args = 0
vim.g.splitjoin_ruby_curly_braces = 0
vim.g.ruby_indent_block_style = 'do'
