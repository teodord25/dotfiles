{pkgs}:
with pkgs; [
  omnisharp-roslyn
  vimPlugins.omnisharp-extended-lsp-nvim

  intelephense
  tinymist

  basedpyright

  lua-language-server
  nodePackages.typescript-language-server
  gopls
  nil

  llvmPackages_19.clang-unwrapped
  vue-language-server
  jdt-language-server
]
