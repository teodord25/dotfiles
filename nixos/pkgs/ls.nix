{pkgs}:
with pkgs; [
  pyright
  lua-language-server
  nodePackages.typescript-language-server
  gopls
  nil

  vue-language-server
]
