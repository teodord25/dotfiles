{
  description = "NixOS config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    alejandra = {
      url = "github:kamadorueda/alejandra/3.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
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
            inputs.rust-overlay.overlays.default
          ];

          environment.systemPackages = with pkgs; [
            rust-bin.stable.latest.default
            templ
            ghostty
            inputs.alejandra.packages.${pkgs.system}.default
          ];
        })
      ];
    };
  };
}
