{
  description = "NixOS system flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    alejandra = {
      url = "github:kamadorueda/alejandra";
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

    ghostty = {
      url = "github:ghostty-org/ghostty";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-code-nix.url = "github:sadjow/claude-code-nix";
    # follows excluded on purpose
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    # One host = its own entrypoint (./hosts/<name>) plus the shared core.
    # Everything else (overlays, package sets, per-host profiles) is imported
    # from those two roots, so adding a host is a single line below.
    mkHost = name:
      nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/${name}
          ./modules/core
        ];
      };
  in {
    nixosConfigurations = {
      work = mkHost "work"; # JetBrains laptop (Intel + Nvidia)
      gaming = mkHost "gaming"; # desktop PC (AMD + AMD), tuned for gaming
    };
  };
}
