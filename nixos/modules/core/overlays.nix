{inputs, ...}: {
  # Overlays only add package attributes; applying them everywhere is harmless
  # for hosts that don't use a given package, and removes the per-host overlay
  # lists that used to be duplicated across every nixosConfiguration in flake.nix.
  nixpkgs.overlays = [
    inputs.ghostty.overlays.default
    inputs.rust-overlay.overlays.default
    inputs.templ.overlays.default
    inputs.claude-code-nix.overlays.default
  ];
}
