{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    vlc
    libreoffice-fresh
  ];
}
