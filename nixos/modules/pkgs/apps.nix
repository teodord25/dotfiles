{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
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
