{
  enable = true;
  # configFile.source = ./.../config.nu;
  extraConfig = ''
    let carapace_completer = {|spans|
    carapace $spans.0 nushell $spans | from json
    }
    $env.config = {
     show_banner: false,
     completions: {
     case_sensitive: false # case-sensitive completions
     quick: true    # set to false to prevent auto-selecting completions
     partial: true    # set to false to prevent partial filling of the prompt
     algorithm: "fuzzy"    # prefix or fuzzy
     external: {
     # set to false to prevent nushell looking into $env.PATH to find more suggestions
    	 enable: true
     # set to lower can improve completion performance at the cost of omitting some options
    	 max_results: 100
    	 completer: $carapace_completer # check 'carapace_completer'
       }
     }
    }
    $env.PATH = ($env.PATH |
    split row (char esep) |
    prepend /home/myuser/.apps |
    append /usr/bin/env
    )

    def tcfg [file] {
      let org = "/home/bane/.config/" + $file
      let tmp = "/home/bane/.config/" + $file + "tmp"

      mv $org $tmp
      cp $tmp $org
      chmod 777 $org
      nvim $org
      rm $org
      mv $tmp $org
    }
    alias tcfg = tcfg

    def smartserve [] {
      cd /home/bane/git/smartserve-table/
      tmux new-window -n docker 'docker compose up'
      sleep 150ms

      tmux select-window -t 1
      tmux split-window -h -l 50
      sleep 150ms

      tmux send-keys "cd e2e" Enter "nix develop" Enter
      tmux split-window -v
      sleep 150ms

      tmux send-keys "git status" Enter
      tmux select-pane -L

      nvim .
    }
    alias ss = smartserve
  '';
  shellAliases = {
    rebuild = "/home/bane/dotfiles/scripts/nu/rebuild.nu";
    ga = "git add";
    gc = "git commit";
    gs = "git status";
    gp = "git push";
    gl = "git log";
    vi = "nvim";
  };
}
