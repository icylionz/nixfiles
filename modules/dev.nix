{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    gcc
    gnumake
    pkg-config
  ];
}

