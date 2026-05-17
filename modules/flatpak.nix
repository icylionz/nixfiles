{pkgs, ...}: {
  services.flatpak.enable = true;

  # Enhanced AMD graphics support for Flatpak
  hardware.graphics = {
    extraPackages = with pkgs; [
      mesa
    ];
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };
}
