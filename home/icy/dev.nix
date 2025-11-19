{ pkgs, ... }:

{
  # Coding / dev tools.
  home.packages = with pkgs; [
    firefox
    brave
    go
    jdk21
    maven
    gradle
    nodejs_22
    pnpm
    python3
    docker-client
    terraform
  ];

  programs.git.enable = true;

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };
}

