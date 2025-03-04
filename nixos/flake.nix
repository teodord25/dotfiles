{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    alejandra.url = "github:kamadorueda/alejandra/3.0.0";
    alejandra.inputs.nixpkgs.follows = "nixpkgs";

    templ.url = "github:a-h/templ";

    hyprland.url = "github:hyprwm/Hyprland";

    ags.url = "github:aylur/ags/v1";

    ghostty.url = "github:ghostty-org/ghostty";
  };

  outputs = {
    self,
    nixpkgs,
    alejandra,
    templ,
    ghostty,
    ...
  } @ inputs: {
    nixosConfigurations = {
      main = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};

        modules = [
          ./hosts/main/configuration.nix
          inputs.home-manager.nixosModules.default

          ({pkgs, ...}: {
            nixpkgs.overlays = [
              inputs.templ.overlays.default
              inputs.ghostty.overlays.default  # Ghostty overlay
            ];

            environment.systemPackages = with pkgs; [
              templ
              ghostty  # From overlay
            ] ++ [
              inputs.alejandra.defaultPackage.${pkgs.system}  # From input
            ];
          })
        ];
      };
    };
  };
}
