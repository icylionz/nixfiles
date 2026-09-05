{
  config,
  pkgs,
  lib,
  ...
}: let
  # Hyprland 0.55+ deprecated the hyprlang (.conf) format in favour of Lua.
  # In the Home Manager lua schema each settings key becomes an `hl.<name>(...)`
  # call; binds are `hl.bind(keys, dispatcher, opts)` where the dispatcher is a
  # raw Lua expression injected via mkLuaInline.
  inline = lib.generators.mkLuaInline;
  mkBind = keys: dsp: {_args = [keys (inline dsp)];};
  mkBindOpts = keys: dsp: opts: {_args = [keys (inline dsp) opts];};
in {
  stylix.targets.hyprlock.enable = false;

  # Terminal used by Hyprland binds.
  programs.kitty.enable = true;

  # Wayland desktop helpers & Hyprland ecosystem tools.
  home.packages = with pkgs; [
    rofi
    awww
    swaynotificationcenter
    grim
    slurp
    wl-clipboard
    swappy
    brightnessctl
    playerctl
    pavucontrol
    thunar
    blueman
    wdisplays
    networkmanagerapplet
    wlogout
    polkit_gnome
  ];

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  xdg.configFile."hypr/hyprland.lua".force = true;

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    # use system hyprland from NixOS module
    package = null;
    portalPackage = null;

    settings = {
      # Global config sections -> hl.config({ ... }).
      config = {
        general = {
          gaps_in = 5;
          gaps_out = 20;
          border_size = 2;
          "col.active_border" = "rgb(${config.lib.stylix.colors.base0D})";
          "col.inactive_border" = "rgb(${config.lib.stylix.colors.base03})";
          layout = "dwindle";
        };

        decoration = {
          rounding = 10;
          blur = {
            enabled = true;
            size = 6;
            passes = 2;
          };
        };

        animations.enabled = true;

        input = {
          kb_layout = "us";
          follow_mouse = 1;
          touchpad.natural_scroll = true;
        };

        cursor.no_hardware_cursors = true;
      };

      # Keep monitor placement stable, but let Hyprland pick the preferred mode on resume.
      monitor = [
        {
          output = "DP-1";
          mode = "preferred";
          position = "0x0";
          scale = 1;
        }
        {
          output = "DP-2";
          mode = "preferred";
          position = "1920x0";
          scale = 1;
        }
        {
          output = "";
          mode = "preferred";
          position = "auto";
          scale = 1;
        }
      ];

      # Custom bezier curve + animations.
      curve._args = [
        "easeOutQuint"
        {
          type = "bezier";
          points = [[0.23 1] [0.32 1]];
        }
      ];

      animation = [
        {leaf = "windows"; enabled = true; speed = 7; bezier = "default";}
        {leaf = "windowsOut"; enabled = true; speed = 7; bezier = "default"; style = "popin 80%";}
        {leaf = "border"; enabled = true; speed = 10; bezier = "default";}
        {leaf = "fade"; enabled = true; speed = 7; bezier = "default";}
        {leaf = "workspaces"; enabled = true; speed = 6; bezier = "default";}
      ];

      # exec-once -> hl.on("hyprland.start", function() ... end).
      on._args = [
        "hyprland.start"
        (inline ''
          function()
            hl.exec_cmd("waybar")
            hl.exec_cmd("swaync")
            hl.exec_cmd("awww-daemon")
            hl.exec_cmd("${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1")
          end'')
      ];

      # Picture-in-Picture window rules.
      window_rule = [
        {match.title = "^(Picture-in-Picture)$"; float = true;}
        {match.title = "^(Picture-in-Picture)$"; pin = true;}
        {match.title = "^(Picture-in-Picture)$"; keep_aspect_ratio = true;}
        {match.title = "^(Picture-in-Picture)$"; border_size = 0;}
      ];

      bind =
        [
          (mkBind "SUPER + Escape" ''hl.dsp.exec_cmd("wlogout")'')
          (mkBind "SUPER + Return" ''hl.dsp.exec_cmd("kitty")'')
          (mkBind "SUPER + ALT + w" ''hl.dsp.exec_cmd("$HOME/.local/bin/wallpaper-picker")'')
          (mkBind "SUPER + q" "hl.dsp.window.kill()")
          (mkBind "SUPER + m" "hl.dsp.exit()")
          (mkBind "SUPER + e" ''hl.dsp.exec_cmd("thunar")'')
          (mkBind "SUPER + v" ''hl.dsp.window.float({ action = "toggle" })'')
          (mkBind "SUPER + s" ''hl.dsp.layout("togglesplit")'')
          (mkBind "SUPER + Space" ''hl.dsp.exec_cmd("rofi -show drun")'')
          (mkBind "SUPER + p" ''hl.dsp.exec_cmd("rofi -show run")'')
          (mkBind "SUPER + f" ''hl.dsp.window.fullscreen({ action = "toggle" })'')
          (mkBind "SUPER + CTRL + l" ''hl.dsp.exec_cmd("hyprlock")'')
          (mkBind "SUPER + ALT + r" ''hl.dsp.exec_cmd("pkill waybar || true && waybar &")'')

          (mkBind "SUPER + CTRL + SHIFT + h" ''hl.dsp.workspace.move({ monitor = "l" })'')
          (mkBind "SUPER + CTRL + SHIFT + l" ''hl.dsp.workspace.move({ monitor = "r" })'')

          (mkBind "SUPER + SHIFT + s" ''hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy')'')
          (mkBind "SHIFT + Print" ''hl.dsp.exec_cmd('grim -g "$(slurp)" - | swappy -f -')'')

          (mkBind "SUPER + h" ''hl.dsp.focus({ direction = "l" })'')
          (mkBind "SUPER + j" ''hl.dsp.focus({ direction = "d" })'')
          (mkBind "SUPER + k" ''hl.dsp.focus({ direction = "u" })'')
          (mkBind "SUPER + l" ''hl.dsp.focus({ direction = "r" })'')

          # Mouse move/resize (bindm -> { mouse = true }).
          (mkBindOpts "SUPER + mouse:272" "hl.dsp.window.drag()" {mouse = true;})
          (mkBindOpts "SUPER + mouse:273" "hl.dsp.window.resize()" {mouse = true;})

          # Volume (bindel -> locked + repeating).
          (mkBindOpts "XF86AudioRaiseVolume" ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+")'' {locked = true; repeating = true;})
          (mkBindOpts "XF86AudioLowerVolume" ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")'' {locked = true; repeating = true;})

          # Media keys (bindl -> locked).
          (mkBindOpts "XF86AudioMute" ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")'' {locked = true;})
          (mkBindOpts "XF86AudioPlay" ''hl.dsp.exec_cmd("playerctl play-pause")'' {locked = true;})
          (mkBindOpts "XF86AudioNext" ''hl.dsp.exec_cmd("playerctl next")'' {locked = true;})
          (mkBindOpts "XF86AudioPrev" ''hl.dsp.exec_cmd("playerctl previous")'' {locked = true;})
        ]
        # Workspace switch / move-to-workspace for 1..9.
        ++ map (n: mkBind "SUPER + ${toString n}" ''hl.dsp.focus({ workspace = "${toString n}" })'') (lib.range 1 9)
        ++ map (n: mkBind "SUPER + SHIFT + ${toString n}" ''hl.dsp.window.move({ workspace = "${toString n}" })'') (lib.range 1 9);
    };
  };

  # Idle + lock integration.
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "hyprlock";
        before_sleep_cmd = "hyprlock";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        {
          timeout = 300;
          on-timeout = "hyprlock";
        }
      ];
    };
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      background = {
        path = "screenshot";
        blur_passes = 2;
        blur_size = 7;
      };

      label = {
        text = "$TIME";
        font_size = 48;
        position = "0, 80";
        halign = "center";
        valign = "center";
      };

      input-field = {
        size = "300, 50";
        position = "0, -20";
        monitor = "";
        rounding = 8;
        fade_on_empty = false;
        placeholder_text = "Password";
        halign = "center";
        valign = "center";
      };
    };
  };
}
