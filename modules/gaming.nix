{pkgs, ...}: {
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    mangohud
    protonup-ng
    lutris
    bottles
    heroic
    wineWow64Packages.stable
    wine
    (wine.override {wineBuild = "wine64";})
    wine64
    wineWow64Packages.staging
    winetricks
    wineWow64Packages.waylandFull
  ];

  environment.sessionVariables.STEAM_EXTRA_COMPAT_TOOLS_PATHS = "$HOME/.steam/root/compatibilitytools.d";
}
