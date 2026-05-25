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

    taplo
    tig
    python3Packages.pip
    cacert
    vscode-langservers-extracted
    typst
    typstPackages."modern-cv"

    sqlitebrowser

    dnsutils
    flyctl
    qemu
    virt-manager # qemu wrapper
    zathura

    inlyne

    dbeaver-bin

    prettier
    ruff

    entr
    delta
    tmuxinator


    # opencode

    luajit
    luajitPackages.lgi

    nushell
  ];
}
