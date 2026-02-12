{pkgs, ...}: {
  # User-facing gaming frontends and social stuff.
  home.packages = with pkgs; [
    steam
    lutris
    bottles
    heroic
    mangohud
    discord
    prismlauncher
  ];
}
