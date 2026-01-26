{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
  ];

  services.flatpak = {
    remotes = [
      {
        name = "flathub";
        location = "https://flathub.org/repo/flathub.flatpakrepo";
      }
    ];

    packages = [
      "com.stremio.Stremio"
      "net.davidotek.pupgui2" # ProtonUp-Qt
    ];

    overrides = {
      "com.stremio.Stremio" = {
        Context.sockets = ["wayland" "fallback-x11" "pulseaudio"];
        Environment = {
          "DISABLE_HARDWARE_ACCELERATION" = "1";
          "LIBVA_DRIVER_NAME" = "radeonsi";
          "ELECTRON_OZONE_PLATFORM_HINT" = "auto";
        };
      };
    };

    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };

    uninstallUnmanaged = false;
  };

  systemd.user.services.flatpak-managed-install = {
    Unit = {
      After = ["graphical-session.target"];
    };
  };
}
