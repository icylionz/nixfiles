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
home.file.".local/bin/wallpaper-picker" = {
  text = ''
    #!/usr/bin/env bash
    # Configuration
    WALLPAPER_DIR="$HOME/Pictures/wallpapers"
    CACHE_DIR="$HOME/.cache/wallpaper-selector"
    THUMBNAIL_WIDTH="250"
    THUMBNAIL_HEIGHT="141"
    
    # Create cache directory if it doesn't exist
    mkdir -p "$CACHE_DIR"
    
    # Function to generate thumbnail
    generate_thumbnail() {
       local input="$1"
       local output="$2"
       magick "$input" -thumbnail "''${THUMBNAIL_WIDTH}x''${THUMBNAIL_HEIGHT}^" -gravity center -extent "''${THUMBNAIL_WIDTH}x''${THUMBNAIL_HEIGHT}" "$output"
    }
    
    # Generate thumbnails and create menu items
    generate_menu() {
       for img in "$WALLPAPER_DIR"/*.{jpg,jpeg,png}; do
          # Skip if no matches found
          [[ -f "$img" ]] || continue
          
          # Generate thumbnail filename
          thumbnail="$CACHE_DIR/$(basename "''${img%.*}").png"
          
          # Generate thumbnail if it doesn't exist or is older than source
          if [[ ! -f "$thumbnail" ]] || [[ "$img" -nt "$thumbnail" ]]; then
             generate_thumbnail "$img" "$thumbnail"
          fi
          
          # Output menu item (filename and path)
          echo -en "img:$thumbnail\x00info:$(basename "$img")\x1f$img\n"
       done
    }
    
    # Use wofi to display grid of wallpapers
    selected=$(generate_menu | wofi --show dmenu \
       --cache-file /dev/null \
       --define "image-size=''${THUMBNAIL_WIDTH}x''${THUMBNAIL_HEIGHT}" \
       --columns 3 \
       --allow-images \
       --insensitive \
       --sort-order=default \
       --prompt "Select Wallpaper" \
       --width 900 \
       --height 600 \
       --style "$HOME/.config/wofi/wallpaper-style.css")
    
    # Set wallpaper if one was selected
    if [ -n "$selected" ]; then
       # Remove the img: prefix to get the cached thumbnail path
       thumbnail_path="''${selected#img:}"
       
       # Get the original filename from the thumbnail path
       original_filename=$(basename "''${thumbnail_path%.*}")
       
       # Find the corresponding original file in the wallpaper directory
       original_path=$(find "$WALLPAPER_DIR" -type f -name "''${original_filename}.*" | head -n1)
       
       # Ensure a valid wallpaper was found before proceeding
       if [ -n "$original_path" ]; then
          # Set wallpaper using swww with the original file
          swww img "$original_path" --transition-type wipe --transition-fps 60
          wal -i "$original_path" -n
          pkill waybar && waybar &
          
          # Optional: Notify user
          notify-send "Wallpaper Changed" "$(basename "$original_path")"
       else
          notify-send "Wallpaper Error" "Could not find the original wallpaper file."
       fi
    fi
  '';
  executable = true;
};
xdg.configFile."wofi/wallpaper-style.css".text = ''
window {
    background-color: #1e1e2e;
    border-radius: 8px;
    border: 2px solid #313244;
}

#input {
    margin: 2px;
    padding: 4px;
    border-radius: 4px;
    border: none;
    background-color: #313244;
    color: #cdd6f4;
}

#inner-box {
  margin: 0px;
}

#outer-box {
  margin: 0px;
}

#scroll {
  margin: 0px;
}

#text {
  margin: 2px;
  color: #cdd6f4;
}

#entry {
  padding: 2px;
  margin: 0px;
  border-radius: 4px;
}

#entry:selected {
  background-color: #313244;
}

#img {
  margin: 2px;
  padding-left: 4px;
  border-radius: 4px;
}
'';
  xdg.configFile."wofi/config".text = ''
# Window settings
width=800
height=600
location=center
show=dmenu
prompt=Select Wallpaper
layer=overlay

# Layout
columns=3
image_size=250x141 # 16:9
allow_images=true
insensitive=true
hide_scroll=true
sort_order=alphabetical

  '';
}
