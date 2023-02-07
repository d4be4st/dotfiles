return {
  {
    "neovim/nvim-lspconfig",
    event = "BufReadPre",
    dependencies = {
      "mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "b0o/schemastore.nvim",
      { "cshuaimin/ssr.nvim", name = "ssr" },
    },
    config = function()
      local nvim_lsp = require('lspconfig')

      local on_attach = function(client, bufnr)
        vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

        -- Mappings.
        -- local ts_builtin = require("telescope.builtin")
        -- vim.keymap.set('n', '<leader>lp', function() vim.diagnostic.goto_prev() end)
        -- vim.keymap.set('n', '<leader>ln', function() vim.diagnostic.goto_next() end)
        -- vim.keymap.set('n', '<leader>ll', function() vim.diagnostic.show_line_diagnostics() end)
        -- vim.keymap.set('n', '<leader>lr', function() vim.lsp.buf.rename() end)
        -- vim.keymap.set('n', '<leader>lh', function() vim.lsp.buf.hover() end)
        -- vim.keymap.set('n', '<leader>lD', function() vim.lsp.buf.declaration() end)
        -- vim.keymap.set('n', '<leader>ld', function() ts_builtin.lsp_definitions() end)
        -- vim.keymap.set('n', '<leader>li', function() vim.lsp.buf.implementation() end)
        -- vim.keymap.set('n', '<leader>ls', function() vim.lsp.buf.signature_help() end)
        -- vim.keymap.set('n', '<leader>lR', function() ts_builtin.lsp_references() end)
        -- vim.keymap.set('n', '<leader>la', function() vim.lsp.buf.code_action() end)
        -- vim.keymap.set('n', '<leader>le', function() ts_builtin.lsp_document_diagnostics() end)
        -- vim.keymap.set('n', '<leader>lt', function() require('trouble').open() end)
        -- vim.keymap.set('n', '<leader>lf', function() vim.lsp.buf.format { async = true } end)
        -- LspSaga
        require("which-key").register({ ["<leader>l"] = { name = "[L]sp" } })
        vim.keymap.set('n', '<leader>lp', function() require("lspsaga.diagnostic"):goto_prev() end,
          { desc = "Goto [P]revious Diagnostics" })
        vim.keymap.set('n', '<leader>ln', function() require("lspsaga.diagnostic"):goto_next() end,
          { desc = "Goto [N]ext Diagnostics" })
        vim.keymap.set('n', '<leader>ll', function() require("lspsaga.diagnostic"):show_diagnostics(arg, 'line') end,
          { desc = "Show [L]ine Diagnostics" })
        vim.keymap.set('n', '<leader>lb', function() require("lspsaga.diagnostic"):show_buf_diagnsotic(arg, 'buffer') end
          ,
          { desc = "Show [B]uffer diagnostics" })
        vim.keymap.set('n', '<leader>la', function() require('lspsaga.codeaction'):code_action() end,
          { desc = "Code [A]ctions" })
        vim.keymap.set('n', '<leader>lh', function() require('lspsaga.hover'):render_hover_doc() end,
          { desc = "[H]over" })
        vim.keymap.set('n', '<leader>lr', function() require('lspsaga.rename'):lsp_rename() end, { desc = "[R]ename" })
        vim.keymap.set('n', '<leader>ld', function() require('lspsaga.definition'):peek_definition() end,
          { desc = "peek [D]efinition" })
        vim.keymap.set('n', '<leader>lg', function() require('lspsaga.definition'):goto_definition() end,
          { desc = "[G]oto Definition" })
        vim.keymap.set('n', '<leader>lo', function() require('lspsaga.outline'):outline() end, { desc = "[O]utline" })
        vim.keymap.set('n', '<leader>l/', function() require('lspsaga.finder'):lsp_finder() end, { desc = "[/] finder" })
        vim.keymap.set('n', '<leader>lf', function() vim.lsp.buf.format { async = true } end, { desc = "[F]ormat" })
        vim.keymap.set({ 'n', 'x' }, '<leader>ls', function() require('ssr').open() end,
          { desc = "[S]earch and replace" })
      end

      -- Configure lua language server for neovim development
      local lua_settings = {
        Lua = {
          runtime = {
            -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
            version = 'LuaJIT',
          },
          diagnostics = {
            -- Get the language server to recognize the `vim` global
            globals = { 'vim' },
          },
          workspace = {
            -- Make the server aware of Neovim runtime files
            library = vim.api.nvim_get_runtime_file("", true),
          },
          -- Do not send telemetry data containing a randomized but unique identifier
          telemetry = {
            enable = false,
          }
        }
      }


      local ruby_attach = function(client, buffer)
        on_attach(client, buffer)

        local callback = function()
          local params = vim.lsp.util.make_text_document_params(buffer)

          client.request(
            'textDocument/diagnostic',
            { textDocument = params },
            function(err, result)
              if err then return end

              vim.lsp.diagnostic.on_publish_diagnostics(
                nil,
                vim.tbl_extend('keep', params, { diagnostics = result.items }),
                { client_id = client.id }
              )
            end
          )
        end

        callback()

        vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePre', 'BufReadPost', 'InsertLeave', 'TextChanged' }, {
          buffer = buffer,
          callback = callback,
        })
      end

      -- config that activates keymaps and enables snippet support
      local function make_config()
        -- local capabilities = vim.lsp.protocol.make_client_capabilities()
        local capabilities = require('cmp_nvim_lsp').default_capabilities()

        return {
          -- enable snippet support
          capabilities = capabilities,
          -- map buffer local keybindings when the language server attaches
          on_attach = on_attach,
        }
      end

      local function setup_servers()
        -- get all installed servers
        local servers = {
          "tsserver",
          "cssls",
          "jsonls",
          "yamlls",
          "sumneko_lua",
          -- "solargraph",
          "ruby_ls",
          "elixirls",
          "html",
          "svelte",
        }

        for _, server in pairs(servers) do
          local config = make_config()

          -- language specific config
          if server == "sumneko_lua" then
            config.settings = lua_settings
          end

          if server == "jsonls" then
            config.settings = {
              json = {
                schemas = require('schemastore').json.schemas(),
                validate = { enable = true },
              }
            }
          end

          if server == "elixirls" then
            config.cmd = { "/Users/stef/bin/elixir-ls/language_server.sh" }
            config.elixirLS = {
              dialyzerEnabled = true,
              fetchDeps = false,
            };
          end

          if server == "html" then
            config.filetypes = { "html", "heex", "erb" }
          end

          if server == "ruby_ls" then
            config.on_attach = ruby_attach
            config.init_options = {
              enabledFeatures = { "codeActions", "diagnostics", "documentHighlights", "documentSymbols", "formatting",
                "inlayHint", "hover" }
            }
          end

          nvim_lsp[server].setup(config)
        end
      end

      vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
        vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = {
          format = function(diagnostic)
            if diagnostic.code then
              return string.format("[%s] %s", diagnostic.code, diagnostic.message)
            else
              return diagnostic.message
            end
          end
        }
      }
      )

      setup_servers()
    end
  },

  -- other
  { "onsails/lspkind-nvim", config = function() require("lspkind").init({ mode = "symbol_text" }) end },
  { "glepnir/lspsaga.nvim",
    event = "BufRead",
    opts = {
      lightbulb = {
        virtual_text = false,
      }
    }
  },
  { "williamboman/mason.nvim", config = function() require("mason").setup() end },
  { "williamboman/mason-lspconfig.nvim", config = function() require("mason-lspconfig").setup() end },
}
