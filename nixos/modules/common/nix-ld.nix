{ pkgs, ... }:
{
  # tells unpatched binaries (those expecting FHS)
  # where to find libs using linker
  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld;
    libraries = with pkgs; [
      stdenv.cc.cc
      zlib

      # add libraries here when binaries complain about missing .so files
    ];
  };
}
