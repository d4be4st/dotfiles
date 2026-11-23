return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ':TSUpdate',
    config = function()
      vim.filetype.add({ extension = { plain = 'plain' } })
      vim.api.nvim_create_autocmd('User', {
        pattern = 'TSUpdate',
        callback = function()
          require('nvim-treesitter.parsers').plain = {
            install_info = {
              url = 'https://github.com/plainlang/tree-sitter-plain',
              revision = '0c18b48f98d0ae5def55f0c9baaab317ccad7471',
              queries = 'queries',
            },
          }
        end,
      })
      local function plain_concepts()
        vim.api.nvim_set_hl(0, '@variable.special.plain', { link = 'Constant' })
      end
      plain_concepts()
      vim.api.nvim_create_autocmd('ColorScheme', { callback = plain_concepts })

      local ts = require 'nvim-treesitter'
      ts.setup()
      ts.install {
        "bash",
        "css",
        "elixir",
        "eex",
        "html",
        "javascript",
        "heex",
        "markdown",
        "markdown_inline",
        "json",
        "plain",
        "lua",
        "ruby",
        "scss",
        "yaml",
      }

      vim.api.nvim_create_autocmd("FileType", {
        callback = function(ev)
          local function enable()
            if not pcall(vim.treesitter.start, ev.buf) then
              return false
            end
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            if ev.match == "markdown" then
              vim.bo[ev.buf].syntax = "on"
            end
            return true
          end

          if enable() then
            return
          end

          local lang = vim.treesitter.language.get_lang(ev.match)
          if lang and vim.list_contains(ts.get_available(), lang) then
            ts.install(lang):await(function()
              if vim.api.nvim_buf_is_valid(ev.buf) then
                enable()
              end
            end)
          end
        end,
      })
    end,
  },
}
