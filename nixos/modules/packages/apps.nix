{pkgs, lib, ...}: {
  environment.systemPackages = with pkgs; [
    anki-bin
    mullvad
    distrobox
    newsboat
    woeusb # rufus
    firefox # WORK browser (default profile); personal one is profiles/firefox.nix
    qbittorrent
    discord
    pavucontrol
    wtype
    thunderbird
    obsidian
    element-desktop

    pi-coding-agent
  ];

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "obsidian" ];
}
