{ pkgs, ... }:

{
  # JSON + CSS for Waybar with Hyprland workspaces. :contentReference[oaicite:6]{index=6}
  xdg.configFile."waybar/config.jsonc".text = ''
    {
      "layer": "top",
      "position": "top",
      "height": 30,
      "spacing": 4,

      "modules-left": ["hyprland/workspaces"],
      "modules-center": ["clock"],
      "modules-right": ["pulseaudio", "network", "cpu", "memory", "battery", "tray"],

      "hyprland/workspaces": {
        "format": "{icon}",
        "on-click": "activate",
        "all-outputs": true,
        "sort-by-number": true,
        "format-icons": {
          "1": "1",
          "2": "2",
          "3": "3",
          "4": "4",
          "5": "5",
          "6": "6",
          "7": "7",
          "8": "8",
          "9": "9",
          "focused": "",
          "default": ""
        }
      },

      "clock": {
        "format": "{:%a %d %b %H:%M}",
        "tooltip-format": "{:%Y-%m-%d}"
      },

      "pulseaudio": {
        "format": "{volume}% {icon}",
        "format-muted": "",
        "format-icons": ["", "", ""]
      },

      "network": {
        "format-wifi": " {signalStrength}%",
        "format-ethernet": "",
        "format-disconnected": "󰌙"
      },

      "cpu": {
        "format": " {usage}%",
        "tooltip": false
      },

      "memory": {
        "format": " {used:0.1f}G",
        "tooltip": false
      },

      "battery": {
        "format": "{capacity}% {icon}",
        "format-charging": " {capacity}%",
        "format-icons": ["", "", "", "", ""]
      },

      "tray": {
        "spacing": 8
      }
    }
  '';

  xdg.configFile."waybar/style.css".text = ''
    * {
      border: none;
      border-radius: 0;
      font-family: "JetBrainsMono Nerd Font", "FiraCode Nerd Font", monospace;
      font-size: 12px;
      min-height: 0;
    }

    window#waybar {
      background: rgba(30, 30, 46, 0.90);
      color: #cdd6f4;
    }

    .modules-left,
    .modules-center,
    .modules-right {
      padding: 0 6px;
    }

    #workspaces button {
      padding: 0 6px;
      background: transparent;
      color: #a6adc8;
    }

    #workspaces button.active {
      background: #89b4fa;
      color: #1e1e2e;
      border-radius: 999px;
    }

    #workspaces button.urgent {
      background: #f38ba8;
      color: #1e1e2e;
    }

    #clock,
    #cpu,
    #memory,
    #battery,
    #network,
    #pulseaudio,
    #tray {
      padding: 0 8px;
    }

    #battery.charging {
      color: #a6e3a1;
    }

    #battery.critical:not(.charging) {
      color: #f38ba8;
    }
  '';
}

