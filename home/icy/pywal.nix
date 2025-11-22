{ config, pkgs, lib, ... }:

{
  programs.pywal.enable = true;

  home.packages = with pkgs; [
    swww
    wofi
    imagemagick
    libnotify
  ];

  programs.bash.initExtra = ''
    (cat ~/.cache/wal/sequences &)
    source ~/.cache/wal/colors-tty.sh
  '';

  # Copy Hyprland's default wallpaper as fallback
  home.activation.setupDefaultWallpaper = lib.hm.dag.entryAfter ["writeBoundary"] ''
    WALLPAPER_DIR="$HOME/Pictures/wallpapers"
    mkdir -p "$WALLPAPER_DIR"
    
    # Copy Hyprland's default wallpaper if our default doesn't exist
    if [ ! -f "$WALLPAPER_DIR/default.png" ]; then
      HYPRLAND_WALL="${pkgs.hyprland}/share/hypr/wall0.png"
      if [ -f "$HYPRLAND_WALL" ]; then
        cp "$HYPRLAND_WALL" "$WALLPAPER_DIR/default.png"
      else
        # Fallback to solid color if Hyprland wallpaper not found
        ${pkgs.imagemagick}/bin/magick -size 1920x1080 'xc:#1e1e2e' "$WALLPAPER_DIR/default.png"
      fi
    fi
    
    # Initialize pywal with default if no cache exists
    if [ ! -f ~/.cache/wal/wal ]; then
      ${pkgs.pywal}/bin/wal -i "$WALLPAPER_DIR/default.png" -n
    fi
  '';

  # Wofi wallpaper picker script
  home.file.".local/bin/wallpaper-picker" = {
    text = ''
      #!/usr/bin/env bash
      
      WALLPAPER_DIR="$HOME/Pictures/wallpapers"
      
      if [ ! -d "$WALLPAPER_DIR" ]; then
        notify-send "Wallpaper Picker" "Directory $WALLPAPER_DIR not found"
        exit 1
      fi
      
      CACHE_DIR="$HOME/.cache/wallpaper-thumbnails"
      mkdir -p "$CACHE_DIR"
      
      SELECTION=$(
        for wallpaper in "$WALLPAPER_DIR"/*; do
          if [[ -f "$wallpaper" ]]; then
            filename=$(basename "$wallpaper")
            thumb="$CACHE_DIR/$filename.thumb.png"
            if [[ ! -f "$thumb" ]]; then
              magick "$wallpaper" -resize 100x100^ -gravity center -extent 100x100 "$thumb" 2>/dev/null
            fi
            echo -en "$filename\0icon\x1f$thumb\n"
          fi
        done | wofi --dmenu \
          --allow-images \
          --allow-markup \
          --insensitive \
          --prompt "Select Wallpaper" \
          --width 600 \
          --height 400 \
          --columns 3
      )
      
      if [ -n "$SELECTION" ]; then
        WALLPAPER="$WALLPAPER_DIR/$SELECTION"
        swww img "$WALLPAPER" --transition-type wipe --transition-fps 60
        wal -i "$WALLPAPER" -n
        pkill waybar && waybar &
        notify-send "Wallpaper Changed" "$SELECTION"
      fi
    '';
    executable = true;
  };

  home.file.".local/bin/random-wallpaper" = {
    text = ''
      #!/usr/bin/env bash
      
      WALLPAPER_DIR="$HOME/Pictures/wallpapers"
      WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)
      
      if [ -n "$WALLPAPER" ]; then
        swww img "$WALLPAPER" --transition-type random --transition-fps 60
        wal -i "$WALLPAPER" -n
        pkill waybar && waybar &
        notify-send "Random Wallpaper" "$(basename "$WALLPAPER")"
      fi
    '';
    executable = true;
  };

  xdg.configFile."wofi/config".text = ''
    allow_images=true
    allow_markup=true
    insensitive=true
    gtk_dark=true
  '';
}
