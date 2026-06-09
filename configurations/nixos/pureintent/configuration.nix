# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, flake, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "pureintent"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Wired (enp1s0) and Wi-Fi (wlp2s0) are on the same LAN. Letting both
  # autoconnect causes ARP flux: the gateway's neighbor entry for our IP flips
  # between the two NIC MACs and the Ethernet path goes silently dead.
  # See docs/LINUX-INTERNET-ISSUES.md.
  #
  # Disable autoconnect on *every* saved Wi-Fi profile (not a single hardcoded
  # SSID) so a newly-joined network can't slip past and bring Wi-Fi up beside
  # Ethernet. Wi-Fi stays usable on demand via `nmcli connection up <name>`.
  systemd.services.nm-wifi-noautoconnect = {
    description = "Disable autoconnect on all Wi-Fi profiles (avoid dual-NIC ARP flux)";
    after = [ "NetworkManager.service" ];
    wants = [ "NetworkManager.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      nmcli=${pkgs.networkmanager}/bin/nmcli
      "$nmcli" -t -f TYPE,NAME connection show | while IFS=: read -r type name; do
        if [ "$type" = "802-11-wireless" ]; then
          "$nmcli" connection modify "$name" connection.autoconnect no || true
        fi
      done
      # Drop any Wi-Fi link that already came up, so the fix applies without a reboot.
      "$nmcli" device disconnect wlp2s0 || true
    '';
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${flake.config.me.username} = {
    isNormalUser = true;
    description = flake.config.me.fullname;
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # The NixOS options manual is rarely consulted locally (options are searched
  # online), but generating it evaluates the doc string of every option — a
  # measurable chunk of eval time. Package man pages (`man git`) are unaffected.
  documentation.nixos.enable = false;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    btop
    python3
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  # TTS: `spd-say "hello"` or `spd-say -l fr "bonjour"`
  # Volume: `wpctl set-volume @DEFAULT_AUDIO_SINK@ 50%` (or 5%+/5%-)
  services.speechd.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
