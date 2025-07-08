{
  description = "My shared shell aliases as an overlay";

  outputs = { self }: {
    overlays.default = final: prev: {
      sharedAliases = ''
        alias gs='git status'
        alias gc='git commit'
        alias gp='git push'
        alias gl='git log'
        alias ga='git add'
      '';
    };
  };
}
