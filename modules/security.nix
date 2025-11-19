{ config, pkgs, lib, ... }:

{
  ########################################
  # Firewall
  ########################################
  networking.firewall = {
    enable = true;
    allowPing = false;
    # Only SSH open by default. Add ports here when you run services.
    allowedTCPPorts = [ 22 ];
    allowedUDPPorts = [ ];
  };

  ########################################
  # SSH hardening
  ########################################
  services.openssh = {
    enable = true;

    # We manage the firewall ourselves above
    openFirewall = false;

    # Map directly to sshd_config options :contentReference[oaicite:0]{index=0}
    settings = {
      PasswordAuthentication = false;    # keys only
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";           # no root SSH at all 
      AllowUsers = [ "icy" ];           # only your user can SSH in
    };
  };

  ########################################
  # sudo hardening
  ########################################
  security.sudo = {
    enable = true;

    # Wheel must type a password.
    wheelNeedsPassword = true;          # default, but set explicitly :contentReference[oaicite:2]{index=2}

    # Only users in wheel can run sudo at all (binary perms tightened). :contentReference[oaicite:3]{index=3}
    execWheelOnly = true;
  };

  ########################################
  # (Optional) audit logging – uncomment if you want logs for everything
  ########################################
  # security.audit.enable = true;        # enables Linux audit subsystem :contentReference[oaicite:4]{index=4}
  # security.auditd.enable = true;       # userspace audit daemon
}

