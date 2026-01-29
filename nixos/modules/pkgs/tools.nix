{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    python3Packages.pip
    cacert
    vscode-langservers-extracted
    typst
    typstPackages."modern-cv"

    sqlitebrowser

    dnsutils
    flyctl
    ntfs3g
    qemu
    virt-manager # qemu wrapper
    bottom
    unrar
    vulkan-tools
    vulkan-loader
    mesa
    zathura

    imagemagick

    prettier

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
  ];
}
