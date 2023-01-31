local nvim_lsp = require('lspconfig')
local ts_builtin = require("telescope.builtin")

local on_attach = function(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  vim.keymap.set('n', '<leader>lp', function() vim.diagnostic.goto_prev() end)
  vim.keymap.set('n', '<leader>ln', function() vim.diagnostic.goto_next() end)
  vim.keymap.set('n', '<leader>ll', function() vim.diagnostic.show_line_diagnostics() end)
  vim.keymap.set('n', '<leader>lr', function() vim.lsp.buf.rename() end)
  vim.keymap.set('n', '<leader>lh', function() vim.lsp.buf.hover() end)
  vim.keymap.set('n', '<leader>lD', function() vim.lsp.buf.declaration() end)
  vim.keymap.set('n', '<leader>ld', function() ts_builtin.lsp_definitions() end)
  vim.keymap.set('n', '<leader>li', function() vim.lsp.buf.implementation() end)
  vim.keymap.set('n', '<leader>ls', function() vim.lsp.buf.signature_help() end)
  vim.keymap.set('n', '<leader>lR', function() ts_builtin.lsp_references() end)
  vim.keymap.set('n', '<leader>la', function() vim.lsp.buf.code_action() end)
  vim.keymap.set('n', '<leader>le', function() ts_builtin.lsp_document_diagnostics() end)
  vim.keymap.set('n', '<leader>lt', function() require('trouble').open() end)
  vim.keymap.set('n', '<leader>lf', function() vim.lsp.buf.format { async = true } end)
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
  local servers = { "tsserver", "cssls", "jsonls", "yamlls", "sumneko_lua", "solargraph", "elixirls", "html", "svelte" }

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
