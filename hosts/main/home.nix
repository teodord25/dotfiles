{...}: {
  home.username = "bane";
  home.homeDirectory = "/home/bane";

  home.stateVersion = "24.05"; # NO TOUCHING

  programs.kitty.enable = true;
  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.settings = {
    general = {
      "sensitivity" = "1.0";
      "layout" = "dwindle";
      "col.active_border" = "rgba(000000ff) rgba(ffffffff) 60deg";
      "col.inactive_border" = "rgba(000000ff)";
    };

    monitor = ",highres,auto,1";

    input = {
      "kb_layout" = "us";
      "kb_model" = "pc105";
    };

    "$mod" = "SUPER";

    # NOTE: bind[flags]:
    # l -> locked, will also work when an input inhibitor (e.g. a lockscreen) is active.
    # r -> release, will trigger on release of a key.
    # e -> repeat, will repeat when held.
    # n -> non-consuming, key/mouse events will be passed to the active window in addition to triggering the dispatcher.
    # m -> mouse, see below.
    # t -> transparent, cannot be shadowed by other binds.
    # i -> ignore mods, will ignore modifiers.
    # s -> separate, will arbitrarily combine keys between each mod/key, see [Keysym combos](#keysym-combos) above.
    # d -> has description, will allow you to write a description for your bind.
    # p -> bypasses the app's requests to inhibit keybinds.

    bind =
      [
        "$mod, Q, killactive"
        "$mod, T, exec, kitty tmux new-session"

        "$mod, D, exec, pkill -x rofi || rofi -show drun"
        "$mod, S, togglefloating,"
        "Alt, Return, fullscreen,"
        "Ctrl+Alt, E, exec, killall waybar || waybar"

        "$mod, E, exec, kitty tmux new-session yazi"
        "$mod, N, exec, kitty tmux new-session nvim"
        "$mod, R, exec, kitty tmux new-session nu /home/bane/nixos/rebuild.nu; input 'Press any key to close..."
        "$mod, F, exec, firefox"
        "Ctrl+Shift, Escape, exec, btm"

        "$mod, Tab, exec, pkill -x rofi || $scrPath/rofilaunch.sh w # launch window switcher"
        "$mod+Shift, E, exec, pkill -x rofi || $scrPath/rofilaunch.sh f # launch file explorer"

        "$mod, P, exec, $scrPath/screenshot.sh s # partial screenshot capture"
        "$mod+Ctrl, P, exec, $scrPath/screenshot.sh sf # partial screenshot capture (frozen screen)"
        "$mod+Alt, P, exec, $scrPath/screenshot.sh m # monitor screenshot capture"
        ", Print, exec, $scrPath/screenshot.sh p # all monitors screenshot capture"

        "$mod+Alt, Right, exec, $scrPath/swwwallpaper.sh -n # next wallpaper"
        "$mod+Alt, Left, exec, $scrPath/swwwallpaper.sh -p # previous wallpaper"
        "$mod, V, exec, pkill -x rofi || $scrPath/cliphist.sh c # launch clipboard"
        "Alt, K, exec, $scrPath/keyboardswitch.sh # switch keyboard layout"

        "Alt, J, togglesplit"

        "$mod, h, movefocus, l"
        "$mod, j, movefocus, d"
        "$mod, k, movefocus, u"
        "$mod, l, movefocus, r"

        "$mod+Shift, h, movewindow, l"
        "$mod+Shift, j, movewindow, d"
        "$mod+Shift, k, movewindow, u"
        "$mod+Shift, l, movewindow, r"
      ]
      ++ (
        builtins.concatLists (builtins.genList (
            i: [
              "$mod, ${toString i}, workspace, ${toString i}"
              "$mod SHIFT, ${toString i}, movetoworkspace, ${toString i}"
              "$mod ALT, ${toString i}, movetoworkspacesilent, ${toString i}"
            ]
          )
          10)
      );

    bindm = [
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
      "$mod, Z, movewindow"
      "$mod, X, resizewindow"
    ];

    bindl = [
      ", XF86AudioMute, exec, $scrPath/volumecontrol.sh -o m # toggle audio mute"
      ", XF86AudioMicMute, exec, $scrPath/volumecontrol.sh -i m # toggle microphone mute"
      ", XF86AudioPlay, exec, playerctl play-pause # toggle between media play and pause"
      ", XF86AudioPause, exec, playerctl play-pause # toggle between media play and pause"
      ", XF86AudioNext, exec, playerctl next # media next"
      ", XF86AudioPrev, exec, playerctl previous # media previous"
    ];

    bindel = [
      ", XF86AudioLowerVolume, exec, $scrPath/volumecontrol.sh -o d # decrease volume"
      ", XF86AudioRaiseVolume, exec, $scrPath/volumecontrol.sh -o i # increase volume"
      ", XF86MonBrightnessUp, exec, $scrPath/brightnesscontrol.sh i # increase brightness"
      ", XF86MonBrightnessDown, exec, $scrPath/brightnesscontrol.sh d # decrease brightness"
    ];

    binde = [
      "$mod+Alt, h, resizeactive, -30 0"
      "$mod+Alt, j, resizeactive, 0 30"
      "$mod+Alt, k, resizeactive, 0 -30"
      "$mod+Alt, l, resizeactive, 30 0"
    ];
  };

  programs = {
    nushell = {
      enable = true;
      # The config.nu can be anywhere you want if you like to edit your Nushell with Nu
      configFile.source = ./.../config.nu;
      # for editing directly to config.nu
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
      '';
      shellAliases = {
        vi = "hx";
        vim = "hx";
        nano = "hx";
      };
    };
    carapace.enable = true;
    carapace.enableNushellIntegration = true;

    starship = {
      enable = true;
      settings = {
        add_newline = true;
        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[➜](bold red)";
        };
      };
    };
  };

  #       alias rebuild = ~/nixos/rebuild.nu
  #       alias reload = home-manager switch
  #       alias ga = git add
  #       alias gc = git commit
  #       alias gs = git status
  #       alias gp = git push
  #
  #       def hyprtest [] {
  #         ls /home/bane/.config/hypr/
  #         mv /home/bane/.config/hypr/hyprland.conf ~/.config/hypr/tmpHypr
  #         cp ~/.config/hypr/tmpHypr ~/.config/hypr/hyprland.conf
  #         nvim ~/.config/hypr/hyprland.conf
  #         rm ~/.config/hypr/hyprland.conf
  #         mv ~/.config/hypr/tmpHypr ~/.config/hypr/hyprland.conf
  #       }
  #       alias hyprtest = hyprtest
  #
  #       plugin add /run/current-system/sw/bin/nu_plugin_gstat
  #

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/bane/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
