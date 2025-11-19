{ config, pkgs, ... }:

{
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
  ];

  programs.bash = {
    enable = true;
    enableCompletion = true;
    initExtra = ''
      PS1="\u@\h:\w\$ "
    '';
  };

  # Common CLI utilities.
  home.packages = with pkgs; [
    ripgrep
    fd
    htop
    btop
    jq
  ];
}

