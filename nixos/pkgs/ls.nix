{pkgs}:
with pkgs; [
  rust-analyzer
  pyright
  lua-language-server
  nodePackages.typescript-language-server
  gopls
  nil
]
