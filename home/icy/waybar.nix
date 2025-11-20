{ config, pkgs, ... }:

{
  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 32;
        margin = "8 8 0 8";

        "modules-left" = [
          "hyprland/workspaces"
          "hyprland/window"
          "group/tasks"
        ];

        "modules-center" = [
          "group/media"
          "clock"
        ];

        "modules-right" = [
          "group/controls"
          "tray"
          "group/system"
          "custom/power"
        ];

        # === GROUPS (ISLANDS) ===

        "group/tasks" = {
          orientation = "horizontal";
          modules = [
            "wlr/taskbar"
          ];
        };

        "group/media" = {
          orientation = "horizontal";
          modules = [
            "mpris"
          ];
        };

        "group/system" = {
          orientation = "horizontal";
          modules = [
            "cpu"
            "memory"
            "temperature"
          ];
        };

        "group/controls" = {
          orientation = "horizontal";
          modules = [
            "pulseaudio"
            "bluetooth"
            "network"
            "custom/display"
            "backlight"
          ];
        };

        # === MODULE CONFIG ===

        "wlr/taskbar" = {
          format = "{icon}";
          icon-size = 20;
          all-outputs = true;
          active-first = true;
          on-click = "activate";
          on-click-middle = "close";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = " mute";
          tooltip = true;
          on-click = "pavucontrol";
          scroll-step = 2;
        };

        bluetooth = {
          format = " {status}";
          format-connected = " {num_connections}";
          format-disabled = " off";
          tooltip = true;
          on-click = "blueman-manager";
        };

        network = {
          format-wifi = " {essid}";
          format-ethernet = "󰈁 {ifname}";
          format-disconnected = "󰖪";
          tooltip = true;
          on-click = "nm-connection-editor";
        };

        "custom/display" = {
          format = "󰍹";
          tooltip = "Display settings";
          on-click = "wdisplays";
        };

        cpu = {
          format = " {usage}%";
          tooltip = true;
          on-click = "kitty -e btop";
        };

        memory = {
          format = " {used:0.1f}G";
          tooltip = true;
          on-click = "kitty -e btop";
        };

        temperature = {
          format = " {temperatureC}°C";
          critical-threshold = 80;
          tooltip = true;
          hwmon-path = "/sys/class/hwmon/hwmon0/temp1_input";
        };

        backlight = {
          format = " {percent}%";
          on-scroll-up = "brightnessctl set +5%";
          on-scroll-down = "brightnessctl set 5%-";
        };

        battery = {
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
          states = {
            good = 80;
            warning = 30;
            critical = 15;
          };
        };

        mpris = {
          format = "{player_icon} {title}";
          max-length = 30;
          tooltip = true;
          on-click = "playerctl play-pause";
          on-scroll-up = "playerctl next";
          on-scroll-down = "playerctl previous";
        };

	clock = {
	  interval = 60;
          format = " {:%a %d %b   %H:%M}";
	  tooltip = true;
	  tooltip-format = "<tt><small>{calendar}</small></tt>";

	  calendar = {
	    mode = "month";
	    mode-mon-col = 3;
	    weeks-pos = "right";
	    on-scroll = 1;

	    format = {
	      months   = "<span color='#cdd6f4'><b>{}</b></span>";
	      days     = "<span color='#b4befe'><b>{}</b></span>";
	      weeks    = "<span color='#a6e3a1'><b>W{}</b></span>";
	      weekdays = "<span color='#fab387'><b>{}</b></span>";
	      today    = "<span color='#f38ba8'><b><u>{}</u></b></span>";
	    };
	  };
	};

        tray = {
          icon-size = 18;
          spacing = 8;
        };

        "custom/power" = {
          format = "";
          tooltip = "Power menu";
          on-click = "wlogout";
        };
      };
    };

    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: "JetBrainsMono Nerd Font", "Iosevka", monospace;
        font-size: 12px;
        min-height: 0;
      }

      /* transparent background, only islands are visible */
      window#waybar {
        background-color: transparent;
      }

      /* islands */
      #left,
      #tasks,
      #media,
      #system,
      #controls,
      #misc {
        background-color: rgba(24, 24, 37, 0.92);
        border-radius: 14px;
        padding: 4px 8px;
        margin: 0 6px;
      }

      #workspaces {
        border-radius: 999px;
        background: transparent;
      }

      #workspaces button {
        border-radius: 999px;
        padding: 2px 8px;
        margin: 2px 3px;
      }

      #workspaces button.active {
        background: rgba(137, 180, 250, 0.4);
      }

      #workspaces button.urgent {
        background: rgba(243, 139, 168, 0.8);
      }

      #taskbar button {
        border-radius: 10px;
        padding: 2px 8px;
        margin: 0 2px;
      }

      #taskbar button.active {
        background-color: rgba(137, 180, 250, 0.3);
      }

      /* make modules inside islands inherit */
      #pulseaudio,
      #bluetooth,
      #network,
      #custom-display,
      #cpu,
      #memory,
      #temperature,
      #backlight,
      #battery,
      #mpris,
      #clock,
      #tray,
      #custom-power {
        background: transparent;
        padding: 0 4px;
        margin: 0 2px;
      }

      #custom-power {
        border-radius: 999px;
        padding: 2px 10px;
        background: rgba(243, 139, 168, 0.9);
        color: #1e1e2e;
      }

      #custom-power:hover {
        background: rgba(243, 139, 168, 1.0);
      }
    '';
  };
}

