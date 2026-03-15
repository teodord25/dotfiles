{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    anki-bin
    mullvad
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
