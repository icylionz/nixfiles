{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # AMD GPU stability fixes
  boot.kernelParams = [
    "amdgpu.dc=1"
    "amdgpu.gpu_recovery=1"
    "amdgpu.ppfeaturemask=0xffffffff"
  ];

  networking.hostName = "icebox";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Barbados";

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = pkg: true;
  nixpkgs.config.permittedInsecurePackages = [
    "electron-36.9.5"
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  # X11 is still needed by GDM; Hyprland itself is Wayland.
  services.xserver.enable = true;
  services.xserver.videoDrivers = ["amdgpu"];
  services.displayManager.gdm.enable = true;
  services.displayManager.gdm.wayland = true;

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
    extraGroups = ["networkmanager" "audio" "wheel" "video"];
    createHome = true;
    home = "/home/icy";
    shell = pkgs.bashInteractive;

    # openssh.authorizedKeys.keys = []
  };

  # Global environment variables for Electron apps
  environment.sessionVariables = {
    # Disable GPU acceleration for Electron apps
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    DISABLE_HARDWARE_ACCELERATION = "1";
  };

  # Minimal system tools; all your desktop apps go via Home Manager.
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
  ];

  system.stateVersion = "25.05";
}
