{
  pkgs,
  inputs,
  ...
}: {
  home.username = "bane";
  home.homeDirectory = "/home/bane";

  home.stateVersion = "24.05"; # NO TOUCHING

  # programs.kitty = {
  #   enable = true;
  #   font = {
  #     name = "DejaVu Sans";
  #   };
  #   settings = {
  #     enable_audio_bell = false;
  #   };
  #   theme = "Tokyo Night";
  # };
  #
  wayland.windowManager.hyprland = import ./hyprland.nix;

  programs.nushell = import ./nushell.nix;

  programs.carapace.enable = true;
  programs.carapace.enableNushellIntegration = true;

  programs.starship = {
    enable = true;
    settings = {
      # show an empty line above the prompt
      add_newline = true;

      # base prompt symbols
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };

      #
      # 1️⃣  Custom “TODO counter” module
      #
      # It will:
      #   • search the current repo/work-dir for the literal string “TODO”
      #   • count the matches
      #   • hide itself if the count is zero (keeps the prompt clean)
      #
      custom = {
        todo = {
          # Fast recursive grep; ignore binary files & git dir
          command = ''
            count=$(rg --hidden -I -g '!{.git,node_modules,target}' -e TODO | wc -l)
            echo $count
          '';

          # Only show when the count is > 0
          when = ''
            rg --hidden -I -g '!{.git,node_modules,target}' -q -e TODO
          '';

          # How it looks:  12
          symbol = "󰛨 "; # nerd-font “checklist” glyph – pick whatever you like
          style = "bold yellow";
          format = "[$symbol$output]($style)"; # → 󰛨 12

          # run in a non-interactive, fast shell
          shell = ["bash" "-cu"];
        };
      };

      #
      # 2️⃣  Put the module into the prompt order
      #
      # $all expands to Starship’s built-ins (directory, git branch, etc.)
      # so we just inject `$todo` before the final $character
      #
      format = "$all$todo$character";
      #            ▲     ▲
      #            |     our custom module reference
      #            built-ins
    };
  };

  imports = [inputs.ags.homeManagerModules.default];

  programs.ags = {
    enable = true;

    # TODO: change htis to actual path when
    # i want to make hm to manage the config
    configDir = null;

    extraPackages = with pkgs; [
      gtksourceview
      webkitgtk
      accountsservice
    ];
  };

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
    # EDITOR = "nvim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
