{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    swww
    wofi
    imagemagick
    libnotify
  ];

  # Setup default wallpaper and symlink
  home.activation.setupDefaultWallpaper = lib.hm.dag.entryAfter ["writeBoundary"] ''
    WALLPAPER_DIR="$HOME/Pictures/wallpapers"
    mkdir -p "$WALLPAPER_DIR"
    
    # Copy Hyprland's default wallpaper if our default doesn't exist
    if [ ! -f "$WALLPAPER_DIR/default.jpg" ]; then
      HYPRLAND_WALL="${pkgs.hyprland}/share/hypr/wall0.png"
      if [ -f "$HYPRLAND_WALL" ]; then
        cp "$HYPRLAND_WALL" "$WALLPAPER_DIR/default.jpg"
      else
        ${pkgs.imagemagick}/bin/magick -size 1920x1080 'xc:#1e1e2e' "$WALLPAPER_DIR/default.jpg"
      fi
    fi
    
    # Create symlink to current wallpaper if it doesn't exist
    if [ ! -L "$HOME/.current-wallpaper" ]; then
      ln -sf "$WALLPAPER_DIR/default.jpg" "$HOME/.current-wallpaper"
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
	    FLAKE_PATH="$HOME/nix"
	    
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
		  [[ -f "$img" ]] || continue
		  
		  thumbnail="$CACHE_DIR/$(basename "''${img%.*}").jpg"
		  
		  if [[ ! -f "$thumbnail" ]] || [[ "$img" -nt "$thumbnail" ]]; then
		     generate_thumbnail "$img" "$thumbnail"
		  fi
		  
		  # Store mapping: thumbnail -> original
		  echo "$thumbnail|$img" >> "$CACHE_DIR/mapping.tmp"
		  
		  echo -en "img:$thumbnail\x00info:$(basename "$img")\n"
	       done
	    }
	    
	    # Clear old mapping
	    rm -f "$CACHE_DIR/mapping.tmp"
	    
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
	    
	    echo "DEBUG: Selected = '$selected'" >&2
	    
	    # Set wallpaper if one was selected
	    if [ -n "$selected" ]; then
	       echo "DEBUG: Selection is not empty" >&2
	       
	       # Extract thumbnail path from the img: prefix
	       thumbnail_path="''${selected#img:}"
	       echo "DEBUG: Thumbnail path = '$thumbnail_path'" >&2
	       
	       # Find original path from mapping
	       original_path=$(grep "^$thumbnail_path|" "$CACHE_DIR/mapping.tmp" | cut -d'|' -f2)
	       echo "DEBUG: Original path = '$original_path'" >&2
	       
	       if [ -f "$original_path" ]; then
		  echo "DEBUG: File exists, setting wallpaper" >&2
		  
		  # Set wallpaper immediately using swww
		  swww img "$original_path" --transition-type wipe --transition-fps 60
		  
		  # Copy to flake directory for Stylix (remove read-only first if needed)
		  rm -f "$FLAKE_PATH/wallpapers/default.jpg"
		  cp "$original_path" "$FLAKE_PATH/wallpapers/default.jpg"
		  chmod u+w "$FLAKE_PATH/wallpapers/default.jpg"
		  
		  # Commit and rebuild
		  notify-send "Wallpaper Changed" "$(basename "$original_path")\nReady to update theme colors"
          
		  (
		    cd "$FLAKE_PATH" && \
		    git add wallpapers/default.png && \
		    git commit -m "Update wallpaper to $(basename "$original_path")"
		  )
		  
		  # Prompt for rebuild (foreground so password works)
		  kitty -e bash -c "sudo nixos-rebuild switch --flake $FLAKE_PATH#icebox && notify-send 'Theme Updated' 'Colors have been applied'"

	       else
		  echo "DEBUG: File does not exist: '$original_path'" >&2
		  notify-send "Wallpaper Error" "Could not find the original wallpaper file: $original_path"
	       fi
	    else
	       echo "DEBUG: No selection made" >&2
	    fi
	    
	    # Cleanup
	    rm -f "$CACHE_DIR/mapping.tmp"
	  '';
	  executable = true;
	};

  # Wofi styling
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
    width=800
    height=600
    location=center
    show=dmenu
    prompt=Select Wallpaper
    layer=overlay
    columns=3
    image_size=250x141
    allow_images=true
    insensitive=true
    hide_scroll=true
    sort_order=alphabetical
  '';
}
