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

    extraPackages = with pkgs; [
      alejandra
    ];

    plugins = with pkgs.vimPlugins; [
      conform-nvim
    ];

    extraLuaConfig = ''
      -- general keymaps
      vim.g.mapleader = " "
      vim.g.maplocalleader = " "

      vim.keymap.set("n", "<leader>ss", "<cmd>w<CR>", { desc = "Save file" })
      vim.keymap.set("i", "jj", "<Esc>", { desc = "Exit insert mode" })

      -- conform.nvim
      require("conform").setup({
        format_on_save = {
          lsp_fallback = true,
          timeout_ms = 2000,
        },
        formatters_by_ft = {
          nix = { "alejandra" },
        },
      })

      vim.keymap.set("n", "<leader>f", function()
        require("conform").format({ async = true })
      end, { desc = "Format file" })
    '';
  };
}

