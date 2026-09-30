{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix

    ../../modules/profiles/cpu-amd.nix
    ../../modules/profiles/gpu-amd.nix
    ../../modules/profiles/gaming.nix
    ../../modules/profiles/performance.nix
    ../../modules/profiles/printer.nix
    ../../modules/profiles/vpn.nix
    ../../modules/profiles/rust.nix
    ../../modules/profiles/tailnet-host.nix
  ];

  networking.hostName = "teodor-gaming-nixos";

  main-user.enable = true;
  main-user.userName = "bane";

  # host-only tooling
  environment.systemPackages = [pkgs.templ]; # from inputs.templ overlay

  system.stateVersion = "24.05";
}
