{
  pkgs,
  inputs,
  ...
}: let
  # Betterfox as *defaults*: a sane baseline that anything below can override.
  # Its user.js is user_pref(...) lines; autoconfig wants defaultPref(...).
  betterfox = pkgs.runCommand "betterfox.cfg" {} ''
    sed 's/^\s*user_pref(/defaultPref(/' ${inputs.betterfox}/user.js > $out
  '';

  amo = slug: "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
  force = slug: {
    installation_mode = "force_installed";
    install_url = amo slug;
  };
in {
  programs.firefox = {
    enable = true;

    # Tridactyl's native messenger: needed for tridactylrc loading, editorcmd,
    # and the tabdump -> diane keybind (config/tridactyl/tabdump.js).
    nativeMessagingHosts.packages = [pkgs.tridactyl-native];

    # The module concatenates these files, then appends autoConfig below,
    # so the locked invariants always come after (and win over) Betterfox.
    autoConfigFiles = [betterfox];

    # Invariants: locked so about:config drift can't silently win.
    autoConfig = ''
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

      // lets userChrome.css work later
      lockPref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

      // Bitwarden owns passwords
      lockPref("signon.rememberSignons", false);
    '';

    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DontCheckDefaultBrowser = true;
      OfferToSaveLogins = false;
      ExtensionSettings = {
        "uBlock0@raymondhill.net" = force "ublock-origin";
        "tridactyl.vim@cmcaine.co.uk" = force "tridactyl-vim";
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = force "bitwarden-password-manager";
      };
    };
  };
}
