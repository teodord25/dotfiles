{pkgs, ...}: {
  # NOTE: packages/lang.nix (imported via profiles/development.nix) also installs
  # `rustup`. Both put cargo/rustc on PATH — pick one. Drop rustup from lang.nix
  # to standardise on this pinned rust-overlay toolchain.
  environment.systemPackages = [
    pkgs.rust-bin.stable.latest.default
  ];
}
