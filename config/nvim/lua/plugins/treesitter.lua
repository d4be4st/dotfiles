require'nvim-treesitter.configs'.setup {
  ensure_installed = {
    "bash",
    -- "crystal",
    "css",
    "elixir",
    "eex",
    "html",
    "javascript",
    "heex",
    "html",
    -- "markdown",
    "json",
    "lua",
    "ruby",
    "scss",
    "scss",
    "yaml",
  },
  highlight = {
    enable = true,              -- false will disable the whole extension
    use_languagetree = true
  }
}
