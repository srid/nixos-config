# Dell XPS 16 DA16260, imported from the fresh NixOS installation.
{ flake, pkgs, ... }:

let
  # Omarchy's kernel (7.2.x + their patch set): nixpkgs' in-tree 7.3 IPU7 stack
  # never gives the OV08X40 sensor a V4L2 subdev node, so the camera HAL cannot
  # start it. Packaged at github:srid/linux-omarchy-nix.
  omarchyKernel =
    flake.inputs.linux-omarchy-nix.packages.${pkgs.stdenv.hostPlatform.system}.default;
  kernelPackages = (pkgs.linuxPackagesFor omarchyKernel).extend (
    _: kernelPkgs: {
      # v4l2loopback 0.15.4 installs via the kernel's `modules_install` target,
      # which runs depmod inside $out; those modules.* files then collide with
      # the kernel's own tree when services.v4l2-relayd merges the module
      # package into boot.extraModulePackages. Keep depmod out of the per-module
      # output; nixpkgs regenerates it for the merged tree it boots.
      v4l2loopback = kernelPkgs.v4l2loopback.overrideAttrs (old: {
        makeFlags = (old.makeFlags or [ ]) ++ [ "DEPMOD=true" ];
      });
    }
  );
in
{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 4;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = kernelPackages;

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

  services.printing.enable = true;

  fonts.packages = [ pkgs.nerd-fonts.caskaydia-cove ];
  fonts.fontconfig.defaultFonts.monospace = [ "CaskaydiaCove Nerd Font" ];

  # Account groups and shell come from the repo's primary-as-admin module.
  users.users.${flake.config.me.username} = {
    description = flake.config.me.fullname;
    packages = [ pkgs.kdePackages.kate ];
  };
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ flake.config.me.username ];
  };
  environment.systemPackages = with pkgs; [ neovim git ];

  # Preserve the version from the initial installation.
  system.stateVersion = "26.05";
}
