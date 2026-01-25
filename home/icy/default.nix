{
  config,
  pkgs,
  ...
}: {
  home.username = "icy";
  home.homeDirectory = "/home/icy";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  imports = [
    ./hyprland.nix
    ./waybar.nix
    ./dev.nix
    ./gaming.nix
    ./spicetify.nix
    ./wallpaper.nix
    ./flatpak.nix
    ./browser.nix
  ];
  xdg.configFile."mimeapps.list".force = true;
  xdg.dataFile."applications/mimeapps.list".force = true;
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = "thunar.desktop";
      "application/x-directory" = "thunar.desktop";
    };
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      vim = "nvim";
      vi = "nvim";
    };
    initExtra = ''
      PS1="\u@\h:\w\$ "

      export PATH="$HOME/.local/bin:$PATH"
    '';
  };

  home.sessionVariables = {
    XDG_DATA_DIRS = "$HOME/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:$XDG_DATA_DIRS";
  };

  # Common CLI utilities.
  home.packages = with pkgs; [
    ripgrep
    fd
    htop
    btop
    jq
    zip
    unzip
  ];
}
