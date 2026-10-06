{
  pkgs,
  inputs,
  ...
}: let
  # Two browsers, one engine, zero shared config:
  #
  #   firefox           plain nixpkgs Firefox, default profile: WORK. Untouched.
  #   firefox-personal  the build below, own profile dir: PERSONAL.
  #
  # Everything personal (policies, prefs, extensions) is baked into this
  # package rather than set via programs.firefox. That module writes
  # /etc/firefox/policies/policies.json, which every nixpkgs Firefox reads,
  # so it would have leaked into the work browser too.

  # Betterfox as *defaults*: a sane baseline that the locked prefs below override.
  # Its user.js is user_pref(...) lines; autoconfig wants defaultPref(...).
  betterfox = pkgs.runCommand "betterfox.cfg" {} ''
    sed 's/^\s*user_pref(/defaultPref(/' ${inputs.betterfox}/user.js > $out
  '';

  amo = slug: "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
  force = slug: {
    installation_mode = "force_installed";
    install_url = amo slug;
  };

  personal = pkgs.wrapFirefox pkgs.firefox-unwrapped {
    # Tridactyl's native messenger: rc loading, editorcmd, tabdump -> diane.
    nativeMessagingHosts = [pkgs.tridactyl-native];

    # The wrapper concatenates these files, then appends extraPrefs,
    # so the locked invariants always come after (and win over) Betterfox.
    extraPrefsFiles = [betterfox];
    extraPrefs = ''
      // fresh slate on every start; crash recovery stays as a safety net
      lockPref("browser.startup.page", 0);
      lockPref("browser.sessionstore.resume_from_crash", true);

      // native vertical tabs
      lockPref("sidebar.revamp", true);
      lockPref("sidebar.verticalTabs", true);

      // always dark (the theme lock is the least reliable line here; if Firefox
      // isn't dark after a rebuild, change it to defaultPref)
      lockPref("extensions.activeThemeID", "firefox-compact-dark@mozilla.org");
      lockPref("layout.css.prefers-color-scheme.content-override", 0);

      // userChrome.css (lives in config/firefox/chrome, linked in by the launcher)
      lockPref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

      // Browser Toolbox (ctrl+alt+shift+i) for inspecting the chrome when a
      // Firefox update breaks a selector in userChrome.css
      defaultPref("devtools.chrome.enabled", true);
      defaultPref("devtools.debugger.remote-enabled", true);

      // Bitwarden owns passwords
      lockPref("signon.rememberSignons", false);
    '';

    extraPolicies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DontCheckDefaultBrowser = true;
      OfferToSaveLogins = false;
      ExtensionSettings = {
        "uBlock0@raymondhill.net" = force "ublock-origin";
        "tridactyl.vim@cmcaine.co.uk" = force "tridactyl-vim";
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = force "bitwarden-password-manager";
        "myallychou@gmail.com" = force "youtube-recommended-videos";                 # Unhook
        "{17c4514d-71fa-4633-8c07-1fe0b354c885}" = force "hide-youtube-thumbnails";  # domdomegg
        "addon@darkreader.org" = force "darkreader";
      };
    };
  };

  # The wrapped package's own binary is also called `firefox`, so it is NOT put
  # on PATH (it would collide with the work one). This launcher is the only
  # way in: separate profile dir outside profiles.ini, separate Wayland app_id.
  launcher = pkgs.writeShellScriptBin "firefox-personal" ''
    dir="$HOME/.mozilla/firefox-personal"
    mkdir -p "$dir"
    # userChrome.css is a stowed dotfile, so CSS edits only need a Firefox
    # restart, not a rebuild. Never clobbers a real chrome/ dir.
    [ -e "$dir/chrome" ] || ln -s "$HOME/.config/firefox/chrome" "$dir/chrome"
    exec ${personal}/bin/firefox --profile "$dir" --name firefox-personal "$@"
  '';

  # Link-handling types the personal browser claims as default.
  webMimeTypes = [
    "text/html"
    "application/xhtml+xml"
    "x-scheme-handler/http"
    "x-scheme-handler/https"
  ];

  desktop = pkgs.makeDesktopItem {
    name = "firefox-personal";
    desktopName = "Firefox (personal)";
    exec = "firefox-personal %U";
    icon = "firefox";
    startupWMClass = "firefox-personal";
    categories = ["Network" "WebBrowser"];
    mimeTypes = webMimeTypes;
  };
in {
  environment.systemPackages = [launcher desktop];

  # Links from anywhere (xdg-open, portals, terminals) go to the personal browser.
  # Note: ~/.config/mimeapps.list overrides this if it has entries for these types.
  xdg.mime.defaultApplications =
    pkgs.lib.genAttrs webMimeTypes (_: "firefox-personal.desktop");
}
