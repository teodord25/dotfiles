{pkgs}:
with pkgs; [
  omnisharp-roslyn
  vimPlugins.omnisharp-extended-lsp-nvim

  tinymist

  basedpyright

  lua-language-server
  gopls
  nil

  llvmPackages_19.clang-unwrapped
  jdt-language-server
]
