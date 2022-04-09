# Linux only. TODO: Will want to consolidate with macOS.
{ pkgs, inputs, system, ... }:
rec {
  imports = [
    ./home/tmux.nix
    ./home/git.nix
    ./home/neovim.nix
    ./home/starship.nix
    ./home/terminal.nix
    ./home/direnv.nix
  ];

  home.packages = with pkgs; [
    gnumake
    psmisc
    lsof
    # psutils -- collides with tex
    usbutils
    ghcid

    cachix
    tig
    procs # no more: ps -ef | grep 
    unzip
    ripgrep
    htop
  ];

  programs.bash = {
    enable = true;
  } // (import ./home/shellcommon.nix { inherit pkgs; });

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
