{pkgs, ...}: {
  virtualisation.docker.enable = true;
  environment.systemPackages = with pkgs; [
    docker-compose
    claude-code
  ];

  imports = [
    ../packages/lang.nix
    ../packages/tree-sitter-grammars.nix
    ../packages/lang-servers.nix
    ../packages/dev-tools.nix
  ];
}
