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
      "net.davidotek.pupgui2" # ProtonUp-Qt
      "org.vinegarhq.Sober" # Roblox
    ];

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
