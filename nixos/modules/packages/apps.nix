{pkgs, ...}: {
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
  ];
}
