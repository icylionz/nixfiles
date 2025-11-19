{ pkgs, ... }:

{
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    mangohud
    protonup-qt
    protonup
    lutris
    bottles
    heroic
    wineWowPackages.stable
    wine
    (wine.override { wineBuild = "wine64"; })
    wine64
    wineWowPackages.staging
    winetricks
    wineWowPackages.waylandFull
  ];

  environment.sessionVariables.STEAM_EXTRA_COMPAT_TOOLS_PATHS =
    "$HOME/.steam/root/compatibilitytools.d";
}

