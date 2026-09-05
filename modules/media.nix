{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    easyeffects
    vlc
    libreoffice-fresh
    blender
  ];

  systemd.user.services.easyeffects = {
    description = "EasyEffects audio processing";
    wantedBy = ["default.target"];
    after = [
      "pipewire.service"
      "pipewire-pulse.service"
    ];
    wants = [
      "pipewire.service"
      "pipewire-pulse.service"
    ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.easyeffects}/bin/easyeffects --hide-window --service-mode";
      Restart = "always";
      RestartSec = 2;
    };
  };
}
