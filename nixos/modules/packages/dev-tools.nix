{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
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

    luajit
    luajitPackages.lgi

    nushell
    jetbrains.rider
  ];
}
