{
  description = "NixOS config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    alejandra = {
      url = "github:kamadorueda/alejandra/3.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    templ = {
      url = "github:a-h/templ";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ags = {
      url = "github:aylur/ags/v1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ghostty = {
      url = "github:ghostty-org/ghostty";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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

        (
          {pkgs, ...}: {
            nixpkgs.overlays = [
              inputs.templ.overlays.default
              inputs.ghostty.overlays.default
              inputs.rust-overlay.overlays.default
            ];

            environment.systemPackages = with pkgs; [
              rust-bin.stable.latest.default
              templ
              ghostty
              ags
              inputs.alejandra.packages.${pkgs.system}.default
            ];
          }
        )
      ];
    };
  };
}
