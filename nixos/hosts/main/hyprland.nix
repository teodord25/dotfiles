{
  enable = true;
  settings = {
    misc = {
      disable_splash_rendering = true;
      disable_hyprland_logo = true;
    };

    general = {
      "sensitivity" = "1.0";
      "layout" = "dwindle";
      # "col.active_border" = "rgba(000000ff) rgba(ffffffff) 60deg";
      # "col.inactive_border" = "rgba(000000ff)";
    };

    decoration = {
      rounding = "8";
    };

    monitor = ",highres,auto,1";

    input = {
      "kb_layout" = "us";
      "kb_model" = "pc105";
    };

    "$mod" = "SUPER";
    "$scripts" = "/home/bane/dotfiles/scripts/";

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
        "$mod       , T      , exec           , kitty tmux new-session                                                 "
        "$mod       , D      , exec           , pkill -x rofi || rofi -show drun                                       "
        "$mod       , E      , exec           , kitty tmux new-session yazi                                            "
        "$mod       , N      , exec           , kitty tmux new-session nvim                                            "
        "$mod       , R      , exec           , kitty tmux new-session $scripts/nu/rebuild.nu                          "
        "$mod       , F      , exec           , firefox                                                                "
        "$mod       , Tab    , exec           , pkill -x rofi || $scripts/rofilaunch.sh w # launch window switcher     "
        "$mod+Shift , E      , exec           , pkill -x rofi || $scripts/rofilaunch.sh f # launch file explorer       "
        "$mod       , P      , exec           , $scripts/nu/screenshot.nu p # partial                                  "
        "$mod+Ctrl  , P      , exec           , $scripts/nu/screenshot.nu m # monitor                                  "
        "Ctrl+Shift , Escape , exec           , btm                                                                    "
        "$mod       , h      , movefocus      , l                                                                      "
        "$mod       , j      , movefocus      , d                                                                      "
        "$mod       , k      , movefocus      , u                                                                      "
        "$mod       , l      , movefocus      , r                                                                      "
        "$mod+Shift , h      , movewindow     , l                                                                      "
        "$mod+Shift , j      , movewindow     , d                                                                      "
        "$mod+Shift , k      , movewindow     , u                                                                      "
        "$mod+Shift , l      , movewindow     , r                                                                      "
        "$mod       , S      , togglefloating                                                                          "
        "$mod       , Q      , killactive                                                                              "
        "Alt        , Return , fullscreen                                                                              "
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

    exec-once = [
      "$scripts/sh/inithypr.sh"
    ];
  };
}
