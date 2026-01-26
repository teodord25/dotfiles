{ pkgs, ... }:
{
  # TODO: do i still need x11?
  services.xserver.enable = true;

  services.displayManager.sddm.enable = true;

  services.libinput.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  programs.xwayland.enable = true;

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  xdg.portal.config.common.default = "*";

  # TODO: might not be needed anymore
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  imports = [
    ../pkgs/hypr.nix
    ../pkgs/apps.nix
  ];

  # to read battery level i think
  services.upower.enable = true;
}
