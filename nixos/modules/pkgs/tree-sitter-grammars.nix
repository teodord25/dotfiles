{pkgs, ...}: {
  environment.systemPackages = with pkgs.tree-sitter-grammars; [
    tree-sitter-rust
    tree-sitter-go
    tree-sitter-lua
    tree-sitter-typst
    tree-sitter-nu
    tree-sitter-vim
  ];
}
