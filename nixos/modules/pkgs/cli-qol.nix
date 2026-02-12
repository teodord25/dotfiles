{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    tree
    bat
    stow
    carapace

    fzf
    zoxide
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

