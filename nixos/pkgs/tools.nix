{pkgs}:
with pkgs; [
  qemu
  virt-manager
  bottom
  unrar
  vulkan-tools
  vulkan-loader
  mesa
  zathura

  texlivePackages.latexmk
  texlive.combined.scheme-full
  imagemagick
  ghostscript

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
]
