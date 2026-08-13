{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix

    ../../modules/profiles/cpu-intel.nix
    ../../modules/profiles/gpu-nvidia.nix
    ../../modules/profiles/development.nix
    ../../modules/profiles/virtualisation.nix
    ../../modules/profiles/rust.nix
  ];

  networking.hostName = "teodor-work-nixos";

  main-user.enable = true;
  main-user.userName = "teodor";

  # work-specific services
  services.cloudflare-warp.enable = true;
  services.thermald.enable = true;

  # work-specific packages
  environment.systemPackages = with pkgs; [
    jetbrains-toolbox
    ungoogled-chromium
    # slack
  ];

  system.stateVersion = "25.11";
}
