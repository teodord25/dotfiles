{pkgs}:
with pkgs; [
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
