{ config, pkgs, ... }:

{
  # GTK theme to follow pywal
  gtk = {
    enable = true;
    
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
    
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  # Qt theme to follow GTK
  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name = "adwaita-dark";
  };

  # XDG portal for theme integration
  xdg.configFile."gtk-3.0/colors.css".text = ''
    @import url("file:///home/icy/.cache/wal/colors-gtk.css");
  '';
  
  xdg.configFile."gtk-4.0/colors.css".text = ''
    @import url("file:///home/icy/.cache/wal/colors-gtk.css");
  '';
}
