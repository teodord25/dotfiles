{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix

    ../../modules/profiles/cpu-amd.nix
    ../../modules/profiles/gpu-amd.nix
    ../../modules/profiles/gaming.nix
    ../../modules/profiles/printer.nix
    ../../modules/profiles/vpn.nix
    ../../modules/profiles/rust.nix
  ];

  networking.hostName = "teodor-personal-nixos";

  main-user.enable = true;
  main-user.userName = "bane";

  # personal-only tooling
  environment.systemPackages = [pkgs.templ]; # from inputs.templ overlay

  system.stateVersion = "24.05";
}
