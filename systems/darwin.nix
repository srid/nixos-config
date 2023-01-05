{ config, pkgs, lib, inputs, system, flake, rosettaPkgs, ... }:

{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    wget
    ripgrep
    sd
    pandoc
    nodejs # Required for VSCode's webhint extension
    nil
    gh
    nixpkgs-fmt
    emanote
    inputs.hci.packages.${system}.hercules-ci-cli

    # We must install Agda globally so that Doom-Emacs' agda config can
    # recognize it. It doesn't matter that our projects use Nix/direnv.
    # 
    # Emacs configuration system assumes global state, and is thus shit. We just work with it.
    # https://github.com/hlissner/doom-emacs/blob/f458f9776049fd7e9523318582feed682e7d575c/modules/lang/agda/config.el#L3-L8
    (rosettaPkgs.agda.withPackages (p: [ p.standard-library ]))
    # rosettaPkgs.idris2
    #rosettaPkgs.coq
    # (rosettaPkgs.haskellPackages.callHackage "agda-language-server" "0.2.1" { })

    # TODO: These should be moved to a separte file?

    # Kill the process with the port open
    # Used only to kill stale ghc.
    (pkgs.writeShellApplication {
      name = "fuckport";
      runtimeInputs = [ jc jq ];
      text = ''
        lsof -i :"$1"
        THEPID=$(lsof -i :"$1" | jc --lsof 2> /dev/null | jq '.[].pid')
        echo "KILL $THEPID ?"
        read -r
        kill "$THEPID"
      '';
    })

    # Spit out the nixpkgs rev pinned by the given flake.
    (pkgs.writeShellApplication {
      name = "nixpkgs-rev";
      text = ''
        NIXPKGS=$(nix flake metadata --json "$1" | jq -r .locks.nodes.root.inputs.nixpkgs)
        nix flake metadata --json "$1" | \
          jq -r .locks.nodes."$NIXPKGS".locked.rev
      '';
    })

    (pkgs.writeShellApplication {
      name = "nixpkgs-update-using";
      text = ''
        REV=$(nixpkgs-rev "$1")
        nix flake lock --update-input nixpkgs --override-input nixpkgs github:nixos/nixpkgs/"$REV"
      '';
    })

  ];

  nix = {
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ]; # Enables use of `nix-shell -p ...` etc
    registry.nixpkgs.flake = inputs.nixpkgs; # Make `nix shell` etc use pinned nixpkgs
    extraOptions = ''
      extra-platforms = aarch64-darwin x86_64-darwin
      experimental-features = nix-command flakes repl-flake
    '';
    # https://nixos.wiki/wiki/Distributed_build
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = (import ./hetzner/ax41.info.nix).publicIP;
        system = "x86_64-linux";
        maxJobs = 10;
      }
    ];
  };
  nixpkgs.config.allowBroken = true;
  nixpkgs.config.allowUnfree = true;

  security.pam.enableSudoTouchIdAuth = true;

  # For home-manager to work.
  users.users.${flake.config.people.myself} = {
    name = flake.config.people.myself;
    home = "/Users/${flake.config.people.myself}";
  };

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # TODO: use agenix to manage 
  # - secrets
  # - ssh keys
  # TODO: consolidate with nixos/hercules.nix
  services.hercules-ci-agent = {
    enable = true;
    package = inputs.hci.packages.${system}.hercules-ci-agent;
  };

  # Create /etc/bashrc that loads the nix-darwin environment.
  # programs.zsh.enable = true; # default shell on catalina
  # programs.fish.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
