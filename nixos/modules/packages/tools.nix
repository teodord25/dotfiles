{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    ghostty # from inputs.ghostty overlay (see modules/core/overlays.nix)
    ntfs3g
    bottom
    unrar
    vulkan-tools
    vulkan-loader
    mesa
    imagemagick
    tridactyl-native # still needed by Zen via scripts/sh/setup/tridactyl.sh; drop with Zen (firefox-personal bundles its own)
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
    satty
  ];
}
