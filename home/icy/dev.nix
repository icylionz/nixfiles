{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.nixvim.homeModules.nixvim
  ];

  # Coding / dev tools.
  home.packages = with pkgs; [
    go
    jdk21
    maven
    gradle
    nodejs_latest
    pnpm
    python3
    podman
    podman-compose
    podman-desktop
    podman-tui
    terraform
    sqlc
    templ
  ];

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "icy";
        email = "kinglioniod@gmail.com";
      };

      init.defaultBranch = "main";
      pull.rebase = "false";
      push.autoSetupRemote = "true";
      core.editor = "nvim";
      diff.colorMoved = "default";
      core.autocrlf = "input";
      status.submoduleSummary = "true";
      credential.helper = "cache --timeout=7200";
    };
  };

  programs.nixvim = {
    enable = true;

    globals.mapleader = " ";
    globals.maplocalleader = " ";

    opts = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
      tabstop = 2;
      expandtab = true;
      smartindent = true;
      wrap = false;
      swapfile = false;
      backup = false;
      undofile = true;
      hlsearch = false;
      incsearch = true;
      termguicolors = true;
      scrolloff = 8;
      updatetime = 50;
      signcolumn = "yes";
      colorcolumn = "80";
    };

    keymaps = [
      # Basic
      {
        mode = "n";
        key = "<leader>ss";
        action = "<cmd>w<CR>";
        options.desc = "Save file";
      }
      {
        mode = "i";
        key = "jj";
        action = "<Esc>";
        options.desc = "Exit insert mode";
      }
      # Buffer navigation
      {
        mode = "n";
        key = "<leader>bn";
        action = "<cmd>bnext<CR>";
        options.desc = "Next buffer";
      }
      {
        mode = "n";
        key = "<leader>bp";
        action = "<cmd>bprevious<CR>";
        options.desc = "Previous buffer";
      }
      {
        mode = "n";
        key = "<leader>xb";
        action = "<cmd>bd<CR>";
        options.desc = "Close buffer";
      }
      {
        mode = "n";
        key = "<leader>xx";
        action = "<cmd>q<CR>";
        options.desc = "Close window/menu";
      }

      # Telescope
      {
        mode = "n";
        key = "<leader>ff";
        action = "<cmd>Telescope find_files<CR>";
        options.desc = "Find files";
      }
      {
        mode = "n";
        key = "<leader>fg";
        action = "<cmd>Telescope live_grep<CR>";
        options.desc = "Live grep";
      }
      {
        mode = "n";
        key = "<leader>fb";
        action = "<cmd>Telescope buffers<CR>";
        options.desc = "Find buffers";
      }
      {
        mode = "n";
        key = "<leader>fh";
        action = "<cmd>Telescope help_tags<CR>";
        options.desc = "Help tags";
      }
      {
        mode = "n";
        key = "<leader>d";
        action = "<cmd>lua vim.diagnostic.open_float()<CR>";
        options.desc = "Show diagnostic at cursor";
      }
      {
        mode = "n";
        key = "<leader>dl";
        action = "<cmd>Telescope diagnostics<CR>";
        options.desc = "List all diagnostics";
      }
      {
        mode = "n";
        key = "]d";
        action = "<cmd>lua vim.diagnostic.goto_next()<CR>";
        options.desc = "Next diagnostic";
      }
      {
        mode = "n";
        key = "[d";
        action = "<cmd>lua vim.diagnostic.goto_prev()<CR>";
        options.desc = "Previous diagnostic";
      }

      # File explorer
      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>Neotree toggle<CR>";
        options.desc = "Toggle file explorer";
      }

      # Terminal
      {
        mode = "n";
        key = "<C-t>";
        action = "<cmd>ToggleTerm<CR>";
        options.desc = "Toggle terminal";
      }
      {
        mode = "t";
        key = "<C-t>";
        action = "<C-\\><C-n><cmd>ToggleTerm<CR>";
        options.desc = "Toggle terminal";
      }
      {
        mode = "t";
        key = "<Esc>";
        action = "<C-\\><C-n>";
        options.desc = "Exit terminal mode";
      }

      # LSP
      {
        mode = "n";
        key = "gd";
        action = "<cmd>lua vim.lsp.buf.definition()<CR>";
        options.desc = "Go to definition";
      }
      {
        mode = "n";
        key = "gr";
        action = "<cmd>lua vim.lsp.buf.references()<CR>";
        options.desc = "Go to references";
      }
      {
        mode = "n";
        key = "K";
        action = "<cmd>lua vim.lsp.buf.hover()<CR>";
        options.desc = "Hover documentation";
      }
      {
        mode = "n";
        key = "<leader>rn";
        action = "<cmd>lua vim.lsp.buf.rename()<CR>";
        options.desc = "Rename symbol";
      }
      {
        mode = "n";
        key = "<leader>ca";
        action = "<cmd>lua vim.lsp.buf.code_action()<CR>";
        options.desc = "Code action";
      }
      {
        mode = "n";
        key = "<leader>f";
        action = "<cmd>lua vim.lsp.buf.format()<CR>";
        options.desc = "Format file";
      }

      # Git
      {
        mode = "n";
        key = "<leader>gp";
        action = "<cmd>Gitsigns preview_hunk<CR>";
        options.desc = "Preview hunk";
      }
      {
        mode = "n";
        key = "<leader>gb";
        action = "<cmd>Gitsigns blame_line<CR>";
        options.desc = "Blame line";
      }
      # Codeium AI
      {
        mode = "i";
        key = "<C-Tab>";
        action = "<Cmd>call codeium#Accept()<CR>";
        options.desc = "Accept Codeium suggestion";
      }
      {
        mode = "i";
        key = "<C-]>";
        action = "<Cmd>call codeium#CycleCompletions(1)<CR>";
        options.desc = "Next Codeium suggestion";
      }
      {
        mode = "i";
        key = "<C-[>";
        action = "<Cmd>call codeium#CycleCompletions(-1)<CR>";
        options.desc = "Previous Codeium suggestion";
      }
      {
        mode = "i";
        key = "<C-x>";
        action = "<Cmd>call codeium#Clear()<CR>";
        options.desc = "Clear Codeium suggestion";
      }

      # Window/pane splits
      {
        mode = "n";
        key = "<leader>sv";
        action = "<cmd>vsplit<CR>";
        options.desc = "Split vertically";
      }
      {
        mode = "n";
        key = "<leader>sh";
        action = "<cmd>split<CR>";
        options.desc = "Split horizontally";
      }
      # Window/pane navigation
      {
        mode = "n";
        key = "<C-h>";
        action = "<C-w>h";
        options.desc = "Move to left window";
      }
      {
        mode = "n";
        key = "<C-j>";
        action = "<C-w>j";
        options.desc = "Move to bottom window";
      }
      {
        mode = "n";
        key = "<C-k>";
        action = "<C-w>k";
        options.desc = "Move to top window";
      }
      {
        mode = "n";
        key = "<C-l>";
        action = "<C-w>l";
        options.desc = "Move to right window";
      }
    ];

    plugins = {
      # UI
      lualine = {
        enable = true;
      };
      web-devicons = {
        enable = true;
      };

      # File explorer
      neo-tree = {
        enable = true;
        settings = {
          close_if_last_window = true;
          window.width = 30;
        };
      };

      # Fuzzy finder
      telescope = {
        enable = true;
        extensions = {
          fzf-native.enable = true;
        };
      };

      # Terminal
      toggleterm = {
        enable = true;
        settings = {
          direction = "horizontal";
          size = 15;
          open_mapping = "[[<C-t>]]";
        };
      };

      # Syntax highlighting
      treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          indent.enable = true;
        };
      };

      # Auto-completion
      cmp = {
        enable = true;
        autoEnableSources = true;

        settings = {
          snippet.expand = "function(args) require('luasnip').lsp_expand(args.body) end";

          mapping = {
            __raw = ''
              cmp.mapping.preset.insert({
                ['<C-Space>'] = cmp.mapping.complete(),
                ['<C-d>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                ['<C-e>'] = cmp.mapping.close(),
                ['<CR>'] = cmp.mapping.confirm({ select = true }),
                ['<Tab>'] = cmp.mapping.select_next_item(),
                ['<S-Tab>'] = cmp.mapping.select_prev_item(),
              })
            '';
          };

          sources = [
            {name = "nvim_lsp";}
            {name = "path";}
            {name = "buffer";}
            {name = "luasnip";}
          ];
        };
      };

      cmp-nvim-lsp.enable = true;
      cmp-buffer.enable = true;
      cmp-path.enable = true;
      cmp_luasnip.enable = true;

      luasnip.enable = true;

      windsurf-vim = {
        enable = true;
      };

      # LSP
      lsp = {
        enable = true;
        servers = {
          nixd.enable = true;
          gopls.enable = true;
          jsonls.enable = true;
          yamlls.enable = true;
          marksman.enable = true;
          ts_ls.enable = true;
          pyright.enable = true;

          # Web development
          html.enable = true;
          cssls.enable = true;
          tailwindcss.enable = true;
          templ.enable = true;

          # SQL
          sqls.enable = true;
        };
      };

      # Formatting
      conform-nvim = {
        enable = true;
        settings = {
          format_on_save = {
            lsp_fallback = true;
            timeout_ms = 2000;
          };
          formatters_by_ft = {
            nix = ["alejandra"];
            go = ["goimports" "gofmt"];
            json = ["prettier"];
            yaml = ["prettier"];
            markdown = ["prettier"];
            javascript = ["prettier"];
            typescript = ["prettier"];
            python = ["black"];
            html = ["prettier"];
            css = ["prettier"];
            templ = ["templ"];
            sql = ["pg_format"];
          };
        };
      };
      # Git integration
      gitsigns = {
        enable = true;
        settings.current_line_blame = true;
      };

      # Auto pairs
      nvim-autopairs.enable = true;

      # Comments
      comment.enable = true;

      # Indent guides
      indent-blankline.enable = true;

      # Which key (show keybindings)
      which-key.enable = true;
    };

    extraPackages = with pkgs; [
      # Nix
      alejandra
      nixd

      # Go
      gopls
      gotools # contains goimports, gofmt, etc.
      delve
      templ

      # JSON/YAML/Markdown
      nodePackages.prettier
      nodePackages.vscode-json-languageserver
      yaml-language-server
      marksman

      # Web development
      nodePackages.vscode-langservers-extracted # html, css, eslint, json
      tailwindcss-language-server

      # SQL
      sqls
      pgformatter

      # Python
      black
      pyright

      # General
      ripgrep
      fd
    ];
  };
}
