{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    tree
    bat
    stow
    carapace
    jq

    fzf
    zoxide

    psmisc
  ];
}
#   html-tidy
#   xh
#   difftastic
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

