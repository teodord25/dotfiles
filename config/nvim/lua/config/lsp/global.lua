local function set_global_keymaps(client, bufnr)
  local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
  end

  map('n', 'gd', vim.lsp.buf.definition, "Go to definition")
  map('n', 'gD', vim.lsp.buf.declaration, "Go to declaration")
  map('n', 'grr', vim.lsp.buf.references, "Go to references")
  map('n', 'gri', vim.lsp.buf.implementation, "Go to implementation")
  map('n', 'gy', vim.lsp.buf.type_definition, "Go to type definition")

  map('n', 'K', vim.lsp.buf.hover, "Hover documentation")
  map('n', '<leader>rn', vim.lsp.buf.rename, "Rename symbol")
  map('n', 'gra', vim.lsp.buf.code_action, "Code actions")
  map({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, "Code actions")

  map('n', '<leader>f', require("conform").format, "Format")

  map('n', '[d', function() vim.diagnostic.jump({ count = -1 }) end, "Previous diagnostic")
  map('n', ']d', function() vim.diagnostic.jump({ count = 1 }) end, "Next diagnostic")
  map('n', '<leader>e', vim.diagnostic.open_float, "Show diagnostic")
  map('n', '<leader>q', vim.diagnostic.setloclist, "Diagnostics to loclist")
end

local function configure_diagnostics()
  vim.diagnostic.config({
    virtual_text = { current_line = true },
    underline = true,
    update_in_insert = true,
    severity_sort = true,
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = "",
        [vim.diagnostic.severity.WARN] = "",
        [vim.diagnostic.severity.INFO] = "",
        [vim.diagnostic.severity.HINT] = "",
      },
    },
    float = {
      border = "rounded",
      source = "if_many",
    },
  })
end

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('global.lsp', { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client then
      set_global_keymaps(client, args.buf)
      configure_diagnostics()
      vim.notify("attached " .. client.name)
    end
  end
})

vim.lsp.config('*', {
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
})
