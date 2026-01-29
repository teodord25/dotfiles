{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    grimblast # screenshots
    wl-clipboard
    rofi
    libnotify
    fastfetch
    ironbar
    swww
  ];
}
