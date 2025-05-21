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

    $env.path ++= ["~/.cargo/bin"]

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

    # in config.nu
    $env.config = {
      hooks: {
        pre_prompt: [{ ||
          # Bail out if direnv isn't on PATH
          if (which direnv | is-empty) {
            return
          }

          # Export env via JSON and load it
          direnv export json | from json | default {} | load-env

          # Handle PATH conversions if needed
          if 'ENV_CONVERSIONS' in $env and 'PATH' in $env.ENV_CONVERSIONS {
            $env.PATH = do $env.ENV_CONVERSIONS.PATH.from_string $env.PATH
          }
        }]
      }
    }

    $env.DIRENV_WARN_TIMEOUT = "999999s"
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
