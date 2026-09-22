# Dell XPS 16 DA16260, imported from the fresh NixOS installation.
{ flake, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # The installer placed the encrypted swap mapping in configuration.nix.
  boot.initrd.luks.devices."luks-95a82689-5e57-4fa0-9b27-acf641489207".device = "/dev/disk/by-uuid/95a82689-5e57-4fa0-9b27-acf641489207";

  networking.hostName = "gossamer";
  networking.networkmanager.enable = true;

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Account groups and shell come from the repo's primary-as-admin module.
  users.users.${flake.config.me.username} = {
    description = flake.config.me.fullname;
    packages = [ pkgs.kdePackages.kate ];
  };
  programs.firefox.enable = true;

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ flake.config.me.username ];
  };
  environment.systemPackages = with pkgs; [ neovim git google-chrome ];

  # Preserve the version from the initial installation.
  system.stateVersion = "26.05";
}
