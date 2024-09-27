{pkgs}:
with pkgs; [
  wineWowPackages.stable
  wineWowPackages.waylandFull
  winetricks

  android-studio
  firefox
  bitwarden
  qbittorrent
  discord
  nheko
  kdePackages.kwallet
  pavucontrol
  qemu
  quickemu
]
