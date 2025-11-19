{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "icebox";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Barbados";

  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # X11 is still needed by GDM; Hyprland itself is Wayland.
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;

  # Audio: PipeWire only.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };

  services.openssh.enable = true;

  users.users.icy = {
    isNormalUser = true;
    description = "icy";
    extraGroups = [ "networkmanager" "audio" "wheel" ];
    createHome = true;
    home = "/home/icy";
    shell = pkgs.bashInteractive;
    
    # openssh.authorizedKeys.keys = []
  };

  # Minimal system tools; all your desktop apps go via Home Manager.
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
  ];

  system.stateVersion = "25.05";
}

