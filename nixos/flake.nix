{
  description = "NixOS system flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
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

    templ = {
      url = "github:a-h/templ";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ghostty = {
      url = "github:ghostty-org/ghostty";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    {
      # work system config
      nixosConfigurations.work = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };

        modules = [
          ./hosts/work/configuration.nix
          ./modules/common
          ./modules/work

          (
            { pkgs, ... }:
            {
              nixpkgs.overlays = [
                inputs.ghostty.overlays.default
                inputs.rust-overlay.overlays.default
              ];

              environment.systemPackages = with pkgs; [
                rust-bin.stable.latest.default
                ghostty
                inputs.alejandra.packages.${pkgs.system}.default
                inputs.zen-browser.packages."${pkgs.system}".default
              ];
            }
          )
        ];
      };

      # personal system config
      nixosConfigurations.personal = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };

        modules = [
          ./hosts/personal/configuration.nix
          ./modules/common
          ./modules/personal

          (
            { pkgs, ... }:
            {
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
                inputs.zen-browser.packages."${pkgs.system}".default
              ];
            }
          )
        ];
      };
    };
}
