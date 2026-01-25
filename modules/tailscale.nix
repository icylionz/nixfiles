{
  config,
  pkgs,
  ...
}: {
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client"; # or "both" if you want to use as exit node
  };

  # Allow Tailscale through firewall
  networking.firewall = {
    # Allow Tailscale's direct connection port
    allowedUDPPorts = [41641];

    # Allow the Tailscale interface
    trustedInterfaces = ["tailscale0"];
  };
}
