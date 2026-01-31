{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    wine64
    mono
    steam-run
    protonup-rs
  ];
}
