{ ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "teodor-work-nixos";

  main-user.enable = true;
  main-user.userName = "teodor";

  system.stateVersion = "25.11";
}
