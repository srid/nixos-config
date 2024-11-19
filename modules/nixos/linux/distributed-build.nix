# https://nixos.wiki/wiki/Distributed_build
{ flake, ... }:
let
  buildHost = "pureintent";
  user = flake.config.me.username;
in
{
  home-manager.users."root" = {
    programs.ssh.matchBlocks = {
      ${buildHost} = {
        inherit user;
        identityFile = "/etc/ssh/ssh_host_ed25519_key";
      };
    };
  };
  # services.openssh.settings.PermitRootLogin = "prohibit-password";
  nix.buildMachines = [
    {
      hostName = buildHost;
      system = "x86_64-linux";
      protocol = "ssh-ng";
      # if the builder supports building for multiple architectures,
      # replace the previous line by, e.g.,
      # systems = ["x86_64-linux" "aarch64-linux"];
      maxJobs = 16;
      speedFactor = 2;
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
