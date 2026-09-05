{ config, pkgs, ... }:

{
  home.file.".local/bin/blue-light-filter" = {
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      default_temp=4500
      min_temp=2000
      max_temp=6500
      state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}"
      temp_file="$state_dir/blue-light-filter-temp"
      active_file="$state_dir/blue-light-filter-active"

      hyprctl_cmd="${pkgs.hyprland}/bin/hyprctl"

      clamp_temp() {
        local temp="$1"

        if (( temp < min_temp )); then
          temp=$min_temp
        elif (( temp > max_temp )); then
          temp=$max_temp
        fi

        printf '%s\n' "$temp"
      }

      load_temp() {
        local temp="$default_temp"

        if [[ -f "$temp_file" ]]; then
          read -r temp < "$temp_file"
        fi

        if [[ ! "$temp" =~ ^[0-9]+$ ]]; then
          temp=$default_temp
        fi

        clamp_temp "$temp"
      }

      save_temp() {
        mkdir -p "$state_dir"
        printf '%s\n' "$(clamp_temp "$1")" > "$temp_file"
      }

      load_active() {
        local active=0

        if [[ -f "$active_file" ]]; then
          read -r active < "$active_file"
        fi

        if [[ "$active" == "1" ]]; then
          printf '1\n'
        else
          printf '0\n'
        fi
      }

      save_active() {
        mkdir -p "$state_dir"
        printf '%s\n' "$1" > "$active_file"
      }

      daemon_running() {
        pgrep -x hyprsunset >/dev/null 2>&1
      }

      format_temp() {
        local temp="$1"
        printf '%d.%dk' "$((temp / 1000))" "$(((temp % 1000) / 100))"
      }

      is_active() {
        [[ "$(load_active)" == "1" ]] && daemon_running
      }

      ensure_daemon() {
        if ! daemon_running; then
          ${pkgs.hyprsunset}/bin/hyprsunset >/dev/null 2>&1 &
          sleep 0.2
        fi
      }

      set_filter() {
        local temp="$1"
        ensure_daemon
        "$hyprctl_cmd" hyprsunset temperature "$temp" >/dev/null
        save_active 1
      }

      clear_filter() {
        ensure_daemon
        "$hyprctl_cmd" hyprsunset identity >/dev/null
        save_active 0
      }

      signal_waybar() {
        pkill -RTMIN+8 waybar >/dev/null 2>&1 || true
      }

      status() {
        local temp
        temp="$(load_temp)"
        local label
        label="$(format_temp "$temp")"

        if is_active; then
          printf '{"text":" %s","class":"active","tooltip":"Blue light filter on (%sK)"}\n' "$label" "$temp"
        else
          printf '{"text":" %s","class":"inactive","tooltip":"Blue light filter off (%sK preset)"}\n' "$label" "$temp"
        fi
      }

      case "''${1:-status}" in
        status)
          status
          ;;
        toggle)
          temp="$(load_temp)"
          if is_active; then
            clear_filter
          else
            set_filter "$temp"
          fi
          signal_waybar
          ;;
        adjust)
          temp="$(load_temp)"
          delta="''${2:-0}"
          temp="$(clamp_temp "$((temp + delta))")"
          save_temp "$temp"

          if is_active; then
            set_filter "$temp"
          fi

          signal_waybar
          ;;
        *)
          printf 'usage: %s [status|toggle|adjust DELTA]\n' "$0" >&2
          exit 1
          ;;
      esac
    '';
    executable = true;
  };

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
            "custom/blue-light"
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

        "custom/blue-light" = {
          return-type = "json";
          format = "{}";
          exec = "$HOME/.local/bin/blue-light-filter status";
          interval = 5;
          signal = 8;
          tooltip = true;
          on-click = "$HOME/.local/bin/blue-light-filter toggle";
          on-scroll-up = "$HOME/.local/bin/blue-light-filter adjust 100";
          on-scroll-down = "$HOME/.local/bin/blue-light-filter adjust -100";
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

	  window#waybar {
	    background-color: transparent;
	  }

	  /* Remove the @import line - stylix handles this */

	  /* Islands - stylix will provide these colors automatically */
	  #left,
	  #tasks,
	  #media,
	  #system,
	  #controls,
	  #misc {
	    background-color: @base00;
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
	    color: @base05;
	  }

	  #workspaces button.active {
	    background: @base0D;
	  }

	  #workspaces button.urgent {
	    background: @base08;
	  }

	  #taskbar button {
	    border-radius: 10px;
	    padding: 2px 8px;
	    margin: 0 2px;
	  }

	  #taskbar button.active {
	    background-color: @base0D;
	  }

	  #pulseaudio,
	  #bluetooth,
	  #network,
	  #custom-display,
	  #custom-blue-light,
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
	    color: @base05;
	  }

	  #custom-power {
	    border-radius: 999px;
	    padding: 2px 10px;
	    background: @base08;
	    color: @base00;
	  }

	  #custom-power:hover {
	    background: @base09;
	  }

	  #custom-blue-light.active {
	    color: @base0A;
	  }

	  #custom-blue-light.inactive {
	    color: @base03;
	  }
	'';
  };
}
