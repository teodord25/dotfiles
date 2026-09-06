{...}: {
  # Applied to every host. Per-host features live in ../profiles and are
  # picked à la carte in each hosts/<name>/default.nix import list.
  imports = [
    ./base.nix
    ./networking.nix
    ./nix-ld.nix
    ./nix-settings.nix
    ./overlays.nix
    ./users.nix
    ./zsh.nix

    ./tailscale.nix

    # every host currently runs the Hyprland desktop
    ../profiles/desktop.nix

    # package sets shared by all hosts
    ../packages/cli-qol.nix
    ../packages/tools.nix
    ../packages/hypr.nix
    ../packages/apps.nix
    ../packages/flake-apps.nix
    ../packages/diane.nix
  ];
}
