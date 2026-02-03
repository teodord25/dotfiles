{pkgs, ...}: {
  virtualisation.docker.enable = true;
  environment.systemPackages = with pkgs; [
    docker-compose
  ];

  imports = [
    ../pkgs/lang.nix
    ../pkgs/tree-sitter-grammars.nix
    ../pkgs/lang-servers.nix
  ];
}
