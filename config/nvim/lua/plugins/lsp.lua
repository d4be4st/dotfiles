local nvim_lsp = require('lspconfig')
local vimp = require("vimp")
local ts_builtin = require("telescope.builtin")

local on_attach = function(client, bufnr)
  -- local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

   -- Mappings.
   vimp.nnoremap('<leader>lp', function() vim.lsp.diagnostic.goto_prev() end)
   vimp.nnoremap('<leader>ln', function() vim.lsp.diagnostic.goto_next() end)
   vimp.nnoremap('<leader>ll', function() vim.lsp.diagnostic.show_line_diagnostics() end)
   vimp.nnoremap('<leader>lr', function() vim.lsp.buf.rename() end)
   vimp.nnoremap('<leader>lh', function() vim.lsp.buf.hover() end)
   vimp.nnoremap('<leader>lD', function() vim.lsp.buf.declaration() end)
   vimp.nnoremap('<leader>ld', function() ts_builtin.lsp_definitions() end)
   vimp.nnoremap('<leader>li', function() vim.lsp.buf.implementation() end)
   vimp.nnoremap('<leader>ls', function() vim.lsp.buf.signature_help() end)
   vimp.nnoremap('<leader>lt', function() vim.lsp.buf.type_definition() end)
   vimp.nnoremap('<leader>lR', function() ts_builtin.lsp_references() end)
   vimp.nnoremap('<leader>la', function() ts_builtin.lsp_code_actions() end)
   vimp.nnoremap('<leader>le', function() ts_builtin.lsp_document_diagnostics() end)


   if client.resolved_capabilities.document_formatting then
     vimp.nnoremap('<leader>lf', function() vim.lsp.buf.formatting() end)
   elseif client.resolved_capabilities.document_range_formatting then
     vimp.nnoremap('<leader>lf', function() vim.lsp.buf.range_formatting() end)
   end
end
-- Configure lua language server for neovim development
local lua_settings = {
  Lua = {
    runtime = {
      -- LuaJIT in the case of Neovim
      version = 'LuaJIT',
      path = vim.split(package.path, ';'),
    },
    diagnostics = {
      -- Get the language server to recognize the `vim` global
      globals = {'vim', 'vimp', 'use'},
    },
    workspace = {
      -- Make the server aware of Neovim runtime files
      library = {
        [vim.fn.expand('$VIMRUNTIME/lua')] = true,
        [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
      },
    },
  }
}

-- config that activates keymaps and enables snippet support
local function make_config()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  return {
    -- enable snippet support
    capabilities = capabilities,
    -- map buffer local keybindings when the language server attaches
    on_attach = on_attach,
  }
end

local function setup_servers()
  -- get all installed servers
 local servers = {"pyright", "tsserver", "cssls", "jsonls", "yamlls", "sumneko_lua", "solargraph", "elixirls"}

  for _, server in pairs(servers) do
    local config = make_config()

    -- language specific config
    if server == "sumneko_lua" then
      config.settings = lua_settings
      config.cmd = {"/Users/stef/.local/share/nvim/lspinstall/lua/./sumneko-lua-language-server"}
    end

    if server == "solargraph" then
      config.flags = { debounce_text_changes = 150 }
    end

    if server == "elixirls" then
      config.cmd = { "/Users/stef/.asdf/installs/elixir/1.11.2//elixir-ls/language_server.sh" }
    end

    nvim_lsp[server].setup(config)
  end
end

vim.lsp.handlers["textDocument/publishDiagnostics"] =
  function(_, _, params, client_id, _)
    local config = { -- your config
      underline = true,
      virtual_text = {
        spacing = 4,
      },
      signs = true,
      update_in_insert = false,
    }
    local uri = params.uri
    local bufnr = vim.uri_to_bufnr(uri)

    if not bufnr then
      return
    end

    local diagnostics = params.diagnostics

    for i, v in ipairs(diagnostics) do
      diagnostics[i].message = string.format("[%s] %s", v.code or v.source, v.message)
    end

    vim.lsp.diagnostic.save(diagnostics, bufnr, client_id)

    if not vim.api.nvim_buf_is_loaded(bufnr) then
      return
    end

    vim.lsp.diagnostic.display(diagnostics, bufnr, client_id, config)
  end

setup_servers()
