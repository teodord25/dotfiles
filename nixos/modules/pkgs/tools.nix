{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    ntfs3g
    bottom
    unrar
    vulkan-tools
    vulkan-loader
    mesa
    imagemagick
    tridactyl-native
    radeontop
    sysstat
    git
    neovim
    wget
    starship
    mpv
    gcc
    yazi
    ripgrep
    tmux
    p7zip
  ];
}
