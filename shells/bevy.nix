{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    pkg-config
    wayland
    libxkbcommon
    alsa-lib
    udev
    vulkan-loader
    xorg.libX11
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXi
  ];

  LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (with pkgs; [
    vulkan-loader
    libxkbcommon
    wayland
  ]);
}
