{ flake, ... }:

{
  # If not using linux-builder, use a VM
  nix.distributedBuilds = true;
  nix.buildMachines = [{
    hostName = "parallels-linux-builder";
    systems = [ "aarch64-linux" "x86_64-linux" ];
    supportedFeatures = [ "kvm" "benchmark" "big-parallel" ];
    maxJobs = 6; # 6 cores
    protocol = "ssh-ng";
    sshUser = flake.config.people.myself;
    sshKey = "/etc/ssh/ssh_host_ed25519_key";
  }];
}
