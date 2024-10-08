-- LSP settings
local nvim_lsp = require 'lspconfig'
local on_attach = function(_, bufnr)
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function()
    if vim.lsp.buf.format then
      vim.lsp.buf.format()
    elseif vim.lsp.buf.formatting then
      vim.lsp.buf.formatting()
    end
  end, { desc = 'Format current buffer with LSP' })
end

vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
vim.keymap.set('n', '<leader>wl', function()
  vim.inspect(vim.lsp.buf.list_workspace_folders())
end, opts)
vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
vim.keymap.set('n', 'gr', '<cmd>Telescope lsp_references<CR>', opts)
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
vim.keymap.set('n', '<leader>so', require('telescope.builtin').lsp_document_symbols, opts)
vim.keymap.set('n', '<leader>ss', require('telescope.builtin').lsp_workspace_symbols, opts)


local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Enable the following language servers
local servers = {
  -- clangd = {},
  rust_analyzer = {},
  zls = {},
  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}

local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  -- ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
    }
  end,
}

require('lspconfig')['clangd'].setup {
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {}
}

require('lspconfig')['rust_analyzer'].setup {
  settings = {
    ['rust-analyzer'] = {
      checkOnSave = {
        command = "clippy";
      },
      diagnostics = {
        enable = false;
      }
    }
  }
}

require('lspconfig')['ts_ls'].setup {
  filetypes = {
    "javascript",
    "typescript"
  },
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {}
}

require('lspconfig')['gopls'].setup {
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
      gofumpt = true,
    },
  },
}

vim.api.nvim_create_user_command("DiagnosticToggle", function()
    local config = vim.diagnostic.config
    local vt = config().virtual_text
    config {
        virtual_text = not vt,
        underline = not vt,
        signs = not vt,
    }
end, { desc = "toggle diagnostic" })
