local on_attach = function(_, buffer)
	local bufmap = function(keys, func)
		vim.keymap.set('n', keys, func, { buffer = buffer })
	end

	bufmap('<leader>r', vim.lsp.buf.rename)
	bufmap('<leader>ca', vim.lsp.buf.code_action)

	bufmap('gd', vim.lsp.buf.definition)
	bufmap('gD', vim.lsp.buf.declaration)
	bufmap('gI', vim.lsp.buf.implementation)
	bufmap('<leader>D', vim.lsp.buf.type_definition)

	bufmap('K', vim.lsp.buf.hover)

	bufmap('gr', require('telescope.builtin').lsp_references)
	bufmap('<leader>s', require('telescope.builtin').lsp_document_symbols)
	bufmap('<leader>S', require('telescope.builtin').lsp_dynamic_workspace_symbols)

	bufmap('<leader>f', vim.lsp.buf.format)
end

------------------------------------------------------------------
-- Compute a unique workspace directory based on your project name.
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local workspace_dir = os.getenv("HOME") .. "/.cache/jdtls/" .. project_name

-- Create the workspace directory if it doesn't exist.
if vim.fn.isdirectory(workspace_dir) == 0 then
  vim.fn.mkdir(workspace_dir, "p")
end

local config = {
  cmd = {"jdtls", "-data", workspace_dir},

  -- Automatically detect the project root (look for .git, gradlew, or mvnw).
  root_dir = vim.fs.dirname(vim.fs.find({"gradlew", ".git", "mvnw"}, { upward = true })[1]),

  settings = { java = {} },

  init_options = { bundles = {} },
}

config.on_attach = on_attach

-- Start (or attach to) the jdtls language server.
require("jdtls").start_or_attach(config)
vim.api.nvim_set_keymap(
  'n',                           -- Normal mode mapping
  '<leader>rs',                  -- Key combination (<leader>rs)
  ':source /home/bane/dotfiles/other/nvim/ftplugin/java.lua<CR>',  -- Command to execute
  { noremap = true, silent = true }
)
