# Linux only. Will want to consolidate with macOS.
{ pkgs, inputs, system, ... }:
rec {
  imports = [
    inputs.nix-doom-emacs.hmModule
    ./home/tmux.nix
    ./home/git.nix
    ./home/neovim.nix
    ./home/starship.nix
    ./home/terminal.nix
  ];

  home.packages = with pkgs; [
    gnumake
    psmisc
    lsof
    # psutils -- collides with tex
    usbutils
    git-crypt
    ghcid

    sqlite
    gcc

    cachix
    tig
    procs # no more: ps -ef | grep 
    tealdeer
    unzip
    dust
    ripgrep
    htop
    bottom # htop alternative
    fzf
    aria2
    wol
    pulsemixer
    # ^ easy to forget these; write SRS?

    hledger
    hledger-web
  ];

  programs = {

    # Leaving this disabled, as it doesn't look like nix-doom-emacs is being
    # maintained or kept up to date anymore.
    doom-emacs = {
      enable = true;
      doomPrivateDir = ./config/doom.d;
    };
    bash = {
      enable = true;
      # XXX: These are needed only on non-NixOS Linux (on NixOS, they are broken)
      #bashrcExtra = ''
      #  . ~/.nix-profile/etc/profile.d/nix.sh
      #  export PATH=$HOME/.nix-profile/bin:$PATH
      #  # https://github.com/nix-community/home-manager/issues/1871#issuecomment-852739277
      #  for completion_script in ~/.nix-profile/share/bash-completion/completions/*
      #  do
      #    source "$completion_script"
      #  done
      #'';
    } // (import ./home/shellcommon.nix { inherit pkgs; });

    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv = {
        enable = true;
      };
    };

  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "thick" = {
        hostname = "192.168.2.14";
      };
    };
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  # home.stateVersion = "21.03";
}
