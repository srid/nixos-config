{ pkgs, flake, rosettaPkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    asciinema
    wget
    ripgrep
    sd
    pandoc
    nodejs # Required for VSCode's webhint extension
    gh
    nixpkgs-fmt
    emanote
    flake.inputs.hci.packages.${pkgs.system}.hercules-ci-cli
    flake.inputs.nixpkgs-match.packages.${pkgs.system}.default
    wezterm

    # We must install Agda globally so that Doom-Emacs' agda config can
    # recognize it. It doesn't matter that our projects use Nix/direnv.
    # 
    # Emacs configuration system assumes global state, and is thus shit. We just work with it.
    # https://github.com/hlissner/doom-emacs/blob/f458f9776049fd7e9523318582feed682e7d575c/modules/lang/agda/config.el#L3-L8
    (rosettaPkgs.agda.withPackages (p: [ p.standard-library ]))
    # rosettaPkgs.idris2
    #rosettaPkgs.coq
    # (rosettaPkgs.haskellPackages.callHackage "agda-language-server" "0.2.1" { })

    # TODO: These should be moved to a separate file?

    # Kill the process with the port open
    # Used only to kill stale ghc.
    # FIXME: This doesn't work when lsof returns *multiple* processes.
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

  ];

  # TODO: Use nix.nix?
  nix = {
    nixPath = [ "nixpkgs=${flake.inputs.nixpkgs}" ]; # Enables use of `nix-shell -p ...` etc
    registry.nixpkgs.flake = flake.inputs.nixpkgs; # Make `nix shell` etc use pinned nixpkgs
    extraOptions = ''
      extra-platforms = aarch64-darwin x86_64-darwin
      experimental-features = nix-command flakes repl-flake
    '';
    # https://nixos.wiki/wiki/Distributed_build
    /* distributedBuilds = true;
      buildMachines = [
      {
        hostName = (import ./hetzner/ax41.info.nix).publicIP;
        system = "x86_64-linux";
        maxJobs = 10;
      }
    ]; */
  };

  security.pam.enableSudoTouchIdAuth = true;

  # For home-manager to work.
  users.users.${flake.config.people.myself} = {
    name = flake.config.people.myself;
    home = "/Users/${flake.config.people.myself}";
  };

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Create /etc/bashrc that loads the nix-darwin environment.
  # programs.zsh.enable = true; # default shell on catalina
  # programs.fish.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
