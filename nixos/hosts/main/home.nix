{pkgs, ...}: {
  home.joebamium = "bane";
  home.homeDirectory = "/home/bane";

  home.stateVersion = "24.05"; # NO TOUCHING

  programs.kitty.enable = true;

  wayland.windowManager.hyprland = import ./hyprland.nix;

  programs.nushell = import ./nushell.nix;

  programs.carapace.enable = true;
  programs.carapace.enableNushellIntegration = true;

  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
    };
  };

  # TODO: might move nvim configs here but seems like a pain rn
  #   programs.neovim = {
  #     enable = true;
  #
  #     # redirects vi/vim/vimdiff calls to nvim
  #     viAlias = true;
  #     vimAlias = true;
  #     vimdiffAlias = true;
  #
  #     extraLuaConfig = ''
  #       ${builtins.readFile ./nvim/init.lua}
  #     '';
  #
  # plugins = with pkgs.vimPlugins; [
  #   {
  #     plugin = nvim-lspconfig;
  #     type = "lua";
  #     config = "${builtins.readFile ./nvim/plugin/lsp.lua}";
  #   }

  #   {
  #     plugin = comment-nvim;
  #     type = "lua";
  #     config = "require('Comment').setup()";
  #   }

  #   {
  #     plugin = gruvbox-nvim;
  #     config = "colorscheme gruvbox";
  #   }

  #   mason
  #   mason-lspconfig

  #   neodev-nvim

  #   nvim-cmp
  #   telescope-nvim
  #   telescope-fzf-native-nvim
  #   cmp_luasnip
  #   cmp-nvim-lsp
  #   luasnip
  #   friendly-snippets
  #   lualine-nvim
  #   nvim-web-devicons

  #   vim-nix

  #   (nvim-treesitter.withPlugins (p: [
  #     p.tree-sitter-nix
  #     p.tree-sitter-vim
  #     p.tree-sitter-bash
  #     p.tree-sitter-lua
  #     p.tree-sitter-python
  #     p.tree-sitter-json
  #   ]))
  # ];
  #};

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