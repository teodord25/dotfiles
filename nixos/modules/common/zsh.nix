{ pkgs, ... }:
{
  # TODO: switch all non data heavy scripts to bash instead of nushell
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };

  users.users.teodor.packages = with pkgs; [
    starship
  ];

  environment.variables.ZDOTDIR = "/home/teodor/.config/zsh";
}
