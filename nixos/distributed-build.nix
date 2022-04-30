{ config, pkgs, ... }:

# https://nixos.wiki/wiki/Distributed_build
{
  nix.buildMachines = [
    {
      hostName = "thick";
      system = "x86_64-linux";
      # if the builder supports building for multiple architectures, 
      # replace the previous line by, e.g.,
      # systems = ["x86_64-linux" "aarch64-linux"];
      maxJobs = 16;
      speedFactor = 3;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      mandatoryFeatures = [ ];
    }
  ];
  nix.distributedBuilds = true;
  # optional, useful when the builder has a faster internet connection than yours
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';
}
