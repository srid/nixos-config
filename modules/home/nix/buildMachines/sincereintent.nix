{ ... }:
{
  # Configure remote building to sincereintent (macOS builder)
  nix.buildMachines = [
    {
      # hostName = "sincereintent"; TAILSCALE problem
      hostName = "192.168.2.245"; # ethernet
      sshUser = "srid";
      systems = [ "aarch64-darwin" ];
      protocol = "ssh-ng";

      maxJobs = 16;
      speedFactor = 2;
      supportedFeatures = [ "benchmark" "big-parallel" ];
      mandatoryFeatures = [ ];

      # We need this!
      sshKey = "/home/srid/.ssh/nix-remote-builder";

      # This too!
      # Run on the remote machine:
      # , base64 -w0 /etc/ssh/ssh_host_ed25519_key.pub
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSU82S2Q2OG5LdFlqNVhTaWgveVlteE96M2o0WUdMUGQxUTE1cTF0dUdsZWUgCg==";
    }
  ];
}
