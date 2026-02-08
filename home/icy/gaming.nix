{pkgs, ...}: {
  # User-facing gaming frontends and social stuff.
  home.packages = with pkgs; [
    steam
    lutris
    bottles
    heroic
    mangohud
    discord
    # Minecraft with dedicated GPU
    (pkgs.writeShellScriptBin "prismlauncher" ''
      export DRI_PRIME=1
      exec ${pkgs.prismlauncher}/bin/prismlauncher "$@"
    '')
  ];
}
