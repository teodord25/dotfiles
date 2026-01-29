{...}: {
  virtualisation.docker.enable = true;

  imports = [
    ../pkgs/lang.nix
    ../pkgs/tree-sitter-grammars.nix
    ../pkgs/lang-servers.nix
  ];
}
