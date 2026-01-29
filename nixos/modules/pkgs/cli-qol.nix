{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    tree
    bat
    stow
    carapace
  ];
}
#   html-tidy
#   xh
#   difftastic
#   zoxide
#   xcp
#   dysk
#   dust
#   erdtree
#   fd
#   procs
#   rm-improved
#   sd
#   tailspin
#   spacer
#   csvlens
#   dog
#   fselect
#   htmlq

