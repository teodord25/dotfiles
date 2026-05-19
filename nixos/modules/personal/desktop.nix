{
  pkgs,
  lib,
  ...
}: {
  # TODO: do i still need x11?
  services.xserver.enable = true;

  # services.displayManager.sddm.enable = true;

  services.libinput.enable = true;

  boot.kernelModules = ["typec_displayport"];

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  programs.xwayland.enable = true;

  environment.systemPackages = [pkgs.wlsunset];

  systemd.user.services.wlsunset = {
    description = "wlsunset";
    wantedBy = ["graphical-session.target"];
    serviceConfig = {
      ExecStart = "${pkgs.wlsunset}/bin/wlsunset -l 45.9 -L 19.6 -t 2500 -T 6500";
      Restart = "on-failure";
    };
  };

  services.flatpak.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
    config = {
      common.default = [
        "hyprland"
        "gtk"
      ];
      hyprland = {
        default = [
          "hyprland"
          "gtk"
        ];
        "org.freedesktop.impl.portal.FileChooser" = ["gtk"];
      };
    };
  };

  # TODO: might not be needed anymore
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  environment.sessionVariables.XDG_DATA_DIRS = lib.mkAfter [
    "/var/lib/flatpak/exports/share"
    "$HOME/.local/share/flatpak/exports/share"
  ];

  imports = [
    ../pkgs/hypr.nix
    ../pkgs/apps.nix
  ];

  # to read battery level i think
  services.upower.enable = true;
}
