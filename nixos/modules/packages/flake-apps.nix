{
  pkgs,
  inputs,
  ...
}: {
  # Packages exposed directly by flake inputs (not via an overlay). Previously
  # these were listed inline in each nixosConfiguration in flake.nix.
  environment.systemPackages = [
    inputs.alejandra.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
