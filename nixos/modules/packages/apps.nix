{pkgs, lib, ...}: {
  environment.systemPackages = with pkgs; [
    anki-bin
    mullvad
    distrobox
    newsboat
    woeusb # rufus
    firefox
    qbittorrent
    discord
    pavucontrol
    wtype
    thunderbird
    obsidian
    element-desktop
  ];

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "obsidian" ];
}
