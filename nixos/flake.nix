{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    alejandra = {
      url = "github:kamadorueda/alejandra/3.0.0";
      follows = "nixpkgs";
    };

    templ.url = "github:a-h/templ";
    hyprland.url = "github:hyprwm/Hyprland";
    ags.url = "github:aylur/ags/v1";
    ghostty.url = "github:ghostty-org/ghostty";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: {
    nixosConfigurations.main = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux"; # Explicit system architecture
      specialArgs = {inherit inputs;};

      modules = [
        ./hosts/main/configuration.nix
        inputs.home-manager.nixosModules.default

        ({pkgs, ...}: {
          nixpkgs.overlays = [
            inputs.templ.overlays.default
            inputs.ghostty.overlays.default
          ];

          environment.systemPackages = with pkgs;
            [
              templ
              ghostty
            ]
            ++ [
              inputs.alejandra.defaultPackage.${pkgs.system}
            ];
        })
      ];
    };
  };
}
