{ pkgs, ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = "Europe/Belgrade";
  i18n.defaultLocale = "en_GB.UTF-8";

  # keyboard layout
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  nixpkgs.config.allowUnfree = true;
  programs.gnupg.agent.enable = true;

  # caps as ctrl / esc mapping
  services.kanata.enable = true;
  services.kanata.keyboards.default.config = ''
    (defsrc caps)
    (defalias escctrl (tap-hold 100 100 esc lctrl))
    (deflayer base @escctrl)
  '';

  imports = [
    ../pkgs/cli-qol.nix
    ../pkgs/tools.nix
  ];

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    roboto
    source-sans-pro
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];
}
