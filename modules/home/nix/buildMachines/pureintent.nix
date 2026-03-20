{ ... }:
{
  # Configure remote building to pureintent (NixOS x86_64-linux builder)
  nix.buildMachines = [
    {
      hostName = "pureintent";
      sshUser = "srid";
      systems = [ "x86_64-linux" ];
      protocol = "ssh-ng";

      maxJobs = 16;
      speedFactor = 2;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      mandatoryFeatures = [ ];

      sshKey = "/Users/srid/.ssh/nix-remote-builder";

      # Run on the remote machine:
      # , base64 -w0 /etc/ssh/ssh_host_ed25519_key.pub
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSU9LZlI3R253cklWZW1QLzFrbmE4amJvTlJlZ0lzYVZMNm1UaTNvWHdNZFUgcm9vdEBuaXhvcwo=";
    }
  ];
}
