{...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "teodor-personal-nixos";

  main-user.enable = true;
  main-user.userName = "bane";

  system.stateVersion = "24.05";
}
