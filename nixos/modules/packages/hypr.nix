{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    grimblast # screenshots
    wl-clipboard
    rofi
    libnotify
    fastfetch
    ironbar
    swww
    bibata-cursors
    playerctl # media keys (hyprland binds)
    brightnessctl # brightness keys (laptop)
  ];
}
