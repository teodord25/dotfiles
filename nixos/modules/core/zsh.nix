{
  pkgs,
  config,
  ...
}: {
  # TODO: switch all non data heavy scripts to bash instead of nushell
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    shellInit = ''
      export ZDOTDIR="/home/${config.main-user.userName}/.config/zsh"
    '';
  };

  users.users.${config.main-user.userName}.packages = with pkgs; [
    starship
  ];

  environment.variables.ZDOTDIR = "/home/${config.main-user.userName}/.config/zsh";
}
