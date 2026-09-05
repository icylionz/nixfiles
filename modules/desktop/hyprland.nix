{ config, pkgs, ... }:

let
  hyprlandPackage = pkgs.hyprland.overrideAttrs (old: {
    passthru = (old.passthru or {}) // {
      providedSessions = ["hyprland"];
    };

    postInstall = (old.postInstall or "") + ''
      substituteInPlace "$out/share/wayland-sessions/hyprland.desktop" \
        --replace-fail "Exec=$out/bin/start-hyprland" "Exec=$out/bin/start-hyprland --path $out/bin/Hyprland"

      rm -f "$out/share/wayland-sessions/hyprland-uwsm.desktop"
    '';
  });
in {
  programs.hyprland = {
    enable = true;
    package = hyprlandPackage;
    xwayland.enable = true;
  };

  services.dbus.enable = true;
  security.polkit.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    font-awesome
  ];

  security.pam.services.hyprlock = {};

  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-gtk
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
}
