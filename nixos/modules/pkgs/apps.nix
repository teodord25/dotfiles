{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    distrobox
    newsboat
    woeusb # rufus
    firefox
    bitwarden-desktop
    qbittorrent
    discord
    kdePackages.kwallet
    pavucontrol
    wtype
    thunderbird
  ];
}
