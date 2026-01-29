-- load global configuration
require("config.lsp.global")

-- load default configurations
require("config.lsp.defaults")

-- then load custom configs
for _, file in ipairs(
  vim.fn.readdir(
    vim.fn.stdpath("config") .. "/lua/config/lsp/custom"
  )
) do
  if file:match("%.lua$") then
    local module_name = "config.lsp.custom." .. file:gsub("%.lua$", "")
    require(module_name)
  end
end
