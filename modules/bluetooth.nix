{ config, pkgs, ... }:

{
  # System Bluetooth support
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Blueman tray / GUI
  services.blueman.enable = true;
}

