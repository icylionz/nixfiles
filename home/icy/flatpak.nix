{inputs, ...}: {
  imports = [
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
  ];

  services.flatpak = {
    remotes = {
      flathub = "https://flathub.org/repo/flathub.flatpakrepo";
    };

    packages = [
      "com.stremio.Stremio"
      "net.davidotek.pupgui2" # ProtonUp-Qt
    ];

    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };
  };
}
