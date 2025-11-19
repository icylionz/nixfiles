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

  programs.git = {
    enable = true;
    userName = "icy";
    userEmail = "kinglioniod@gmail.com";

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase        = "false";
      push.autoSetupRemote = "true";

      core.editor = "nvim";

      diff.colorMoved = "default";

      core.autocrlf = "input";

      status.submoduleSummary = "true";

      credential.helper = "cache --timeout=7200";
    };
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    extraConfig = ''
	inoremap jj <Esc>
    '';
  };
}

