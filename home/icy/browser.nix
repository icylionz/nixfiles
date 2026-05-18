{pkgs, ...}: {
  stylix.targets.firefox.profileNames = ["icy"];

  programs.firefox = {
    enable = true;
    configPath = ".mozilla/firefox";

    profiles.icy = {
      isDefault = true;

      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

        # Performance settings
        "gfx.webrender.all" = true;
        "media.ffmpeg.vaapi.enabled" = true;

        "browser.aboutConfig.showWarning" = false;
        "browser.compactmode.show" = true;
      };
    };
  };
}
