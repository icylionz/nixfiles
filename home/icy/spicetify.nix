{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system};
in {
  imports = [
    inputs.spicetify-nix.homeManagerModules.default
  ];

  programs.spicetify = {
    enable = true;
    enabledExtensions = with spicePkgs.extensions; [
      adblock
      shuffle
      fullAppDisplay
    ];
  };

  # Workaround for Spotify crashes
  home.file.".config/spotify-flags.conf".text = ''
    --disable-gpu
    --disable-software-rasterizer
    --disable-gpu-compositing
  '';
}
