# My Linux VM running on macOS
{ flake, modulesPath, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    flake.inputs.disko.nixosModules.disko
  ];
  system.stateVersion = "23.11";
  services.openssh.enable = true;
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    binfmt.emulatedSystems = [ "x86_64-linux" ]; # For cross-compiling
    swraid.mdadmConf = ''
      MAILADDR srid@srid.ca
    '';
  };
  nixpkgs.hostPlatform = "aarch64-linux";

  networking = {
    hostName = "here";
    networkmanager.enable = true;
  };
  time.timeZone = "America/New_York";
  disko.devices = import ./disko/vm.nix;
}
