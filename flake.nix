{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    alejandra.url = "github:kamadorueda/alejandra/3.0.0";
    alejandra.inputs.nixpkgs.follows = "nixpkgs";

    templ.url = "github:a-h/templ";
  };

  outputs = {
    self,
    nixpkgs,
    alejandra,
    ...
  } @ inputs: {
    nixosConfigurations = {
      main = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};

        modules = [
          ./hosts/main/configuration.nix
          inputs.home-manager.nixosModules.default

          {
            environment.systemPackages = [alejandra.defaultPackage.x86_64-linux];
          }

          ({pkgs, ...}: {
            nixpkgs.overlays = [
              templ.overlay.default
            ];
            environment.systemPackages = with pkgs; [
              templ
            ];
          })
        ];
      };

      work = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/work/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
    };
  };
}
