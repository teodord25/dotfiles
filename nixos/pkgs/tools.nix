{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    python3Packages.pip
    cacert
    vscode-langservers-extracted
    wine64
    mono
    typst
    typstPackages."modern-cv"

    sqlitebrowser

    dnsutils
    flyctl
    ntfs3g
    qemu
    virt-manager
    bottom
    unrar
    vulkan-tools
    vulkan-loader
    mesa
    zathura

    imagemagick

    git
    neovim
    wget
    nushell
    starship
    mpv
    gcc
    yazi
    ripgrep
    tmux
    p7zip
    steam-run
  ];
}
