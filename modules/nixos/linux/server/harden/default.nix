{
  imports = [
    ./basics.nix
  ];

  services = {
    fail2ban = {
      enable = true;
      ignoreIP = [
        "100.80.93.92" # Tailscale "appreciate"
      ];
    };
  };
}
