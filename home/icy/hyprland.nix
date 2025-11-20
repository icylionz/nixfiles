{ config, pkgs, ... }:

{
  # Terminal used by Hyprland binds.
  programs.kitty.enable = true;

  # Wayland desktop helpers & Hyprland ecosystem tools.
  home.packages = with pkgs; [
    rofi-wayland
    hyprpaper
    swaynotificationcenter   # binary is `swaync`
    grim
    slurp
    wl-clipboard
    swappy
    brightnessctl
    playerctl
    pavucontrol
    xfce.thunar
    blueman
    wdisplays
    networkmanagerapplet
    wlogout
  ];

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  # Hyprpaper config (simple single-wallpaper setup).
  xdg.configFile."hypr/hyprpaper.conf".text = ''
    preload = ~/Pictures/wallpapers/default.jpg
    wallpaper = ,~/Pictures/wallpapers/default.jpg
  '';

  wayland.windowManager.hyprland = {
    enable = true;
    # use system hyprland from NixOS module
    package = null;
    portalPackage = null;

    settings = {
      "$mod" = "SUPER";

      monitor = [
        # default: preferred mode, auto position, scale 1.0
        ",preferred,auto,1"
      ];

      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        "col.active_border" = "rgba(89b4faee)";
        "col.inactive_border" = "rgba(313244aa)";
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

      animations = {
        enabled = true;
        bezier = [
          "easeOutQuint,0.23,1,0.32,1"
        ];
        animation = [
          "windows,1,7,default"
          "windowsOut,1,7,default,popin 80%"
          "border,1,10,default"
          "fade,1,7,default"
          "workspaces,1,6,default"
        ];
      };

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = true;
        };
      };

      gestures = {
        workspace_swipe = true;
      };

      exec-once = [
        "hyprpaper"
        "waybar"
        "swaync"
      ];

      bind = [
        "$mod,Escape,exec,wlogout"
        "$mod,Return,exec,kitty"
        "$mod,W,killactive,"
        "$mod,M,exit,"
        "$mod,E,exec,thunar"
        "$mod,V,togglefloating,"
        "$mod,Space,exec,rofi -show drun"
        "$mod,P,exec,rofi -show run"
        "$mod,F,fullscreen,"
        "$mod,L,exec,hyprlock"

        "$mod,1,workspace,1"
        "$mod,2,workspace,2"
        "$mod,3,workspace,3"
        "$mod,4,workspace,4"
        "$mod,5,workspace,5"
        "$mod,6,workspace,6"
        "$mod,7,workspace,7"
        "$mod,8,workspace,8"
        "$mod,9,workspace,9"

        "$mod SHIFT,1,movetoworkspace,1"
        "$mod SHIFT,2,movetoworkspace,2"
        "$mod SHIFT,3,movetoworkspace,3"
        "$mod SHIFT,4,movetoworkspace,4"
        "$mod SHIFT,5,movetoworkspace,5"
        "$mod SHIFT,6,movetoworkspace,6"
        "$mod SHIFT,7,movetoworkspace,7"
        "$mod SHIFT,8,movetoworkspace,8"
        "$mod SHIFT,9,movetoworkspace,9"

	"$mod CTRL SHIFT,h,movecurrentworkspacetomonitor,l"
	"$mod CTRL SHIFT,l,movecurrentworkspacetomonitor,r"

	# NEW: screenshots
        # area to clipboard
        "$mod SHIFT,S,exec,grim -g \"$(slurp)\" - | wl-copy"
        # area to swappy (annotate + save)
        "SHIFT,Print,exec,grim -g \"$(slurp)\" - | swappy -f -"
      ];

      bindm = [
        "$mod,mouse:272,movewindow"
        "$mod,mouse:273,resizewindow"
      ];
      # Volume keys (repeat while held, work on lockscreen)
	    bindel = [
	      ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
	      ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
	    ];

	    # Media + mute keys
	    bindl = [
	      ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
	      ", XF86AudioPlay, exec, playerctl play-pause"
	      ", XF86AudioNext, exec, playerctl next"
	      ", XF86AudioPrev, exec, playerctl previous"
	    ];
    };
  };

  # Idle + lock integration. :contentReference[oaicite:4]{index=4}
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
        {
          timeout = 600;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
      };

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
        font_size = 16;
        halign = "center";
        valign = "center";
      };
    };
  };
}

