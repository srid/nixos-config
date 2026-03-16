{ flake, config, pkgs, ... }:

let
  inherit (flake) inputs;
  inherit (flake.inputs) self;
in
{
  imports = [
    inputs.vira.homeManagerModules.vira
  ];

  home.packages = [
    config.services.vira.package # For CLI
  ];

  # HACK: Hardcoded UID 1000 - should use config.users.users.srid.uid or similar.
  # The vira module requires an absolute path, but agenix home-manager uses
  # ${XDG_RUNTIME_DIR} which isn't resolved at evaluation time.
  # TODO: Find a proper solution - perhaps contribute a fix to vira to accept
  # runtime paths, or configure agenix to use a static path.
  age.secrets."vira-github-private-key.age" = {
    file = self + /secrets/vira-github-private-key.age;
    path = "/run/user/1000/agenix/vira-github-private-key.age";
  };
  age.secrets."vira-github-webhook-secret.age" = {
    file = self + /secrets/vira-github-webhook-secret.age;
    path = "/run/user/1000/agenix/vira-github-webhook-secret.age";
  };

  nix.settings.trusted-users = [ "srid" ]; # For cache?

  services.vira = {
    systemd.environment = {
      NIX_SSHOPTS = "-o ConnectTimeout=10 -o ServerAliveInterval=60";
    };
    enable = true;
    port = 5001;
    hostname = "100.122.32.106"; # Tailscale IP of pureintent
    # https = false; # Using tailscale services
    autoResetState = true;
    autoBuildNewBranches = true;
    package = inputs.vira.packages.${pkgs.stdenv.hostPlatform.system}.default;

    /*
      github = {
      appId = 2989507;
      privateKeyFile = config.age.secrets."vira-github-private-key.age".path;
      webhookSecretFile = config.age.secrets."vira-github-webhook-secret.age".path;
      };
    */

    initialState = {
      repositories = {
        AI = "https://github.com/srid/AI.git";
        nixos-config = "https://github.com/srid/nixos-config.git";
        nixos-unified-template = "https://github.com/juspay/nixos-unified-template.git";
        nixos-unified = "https://github.com/srid/nixos-unified.git";
        hackage-publish = "https://github.com/srid/hackage-publish.git";
        haskell-flake = "https://github.com/srid/haskell-flake.git";
        heist-extra = "https://github.com/srid/heist-extra.git";
        tail-hs = "https://github.com/srid/tail-hs.git";
        rust-flake = "https://github.com/juspay/rust-flake.git";
        rust-nix-template = "https://github.com/srid/rust-nix-template.git";
        # services-flake = "https://github.com/juspay/services-flake.git";
        process-compose-flake = "https://github.com/Platonic-Systems/process-compose-flake.git";
        oc = "https://github.com/juspay/oc.git";
        vira = "https://github.com/juspay/vira.git";
        skills = "https://github.com/juspay/skills.git";
        emanote = "https://github.com/srid/emanote.git";
        unionmount = "https://github.com/srid/unionmount.git";
        ema = "https://github.com/srid/ema.git";
        srid = "https://github.com/srid/srid.git";
        imako = "https://github.com/srid/imako.git";
        opencode-haskell = "https://github.com/srid/opencode-haskell.git";
        landrun-nix = "https://github.com/srid/landrun-nix.git";
        haskell-template = "https://github.com/srid/haskell-template.git";
        commonmark-wikilink = "https://github.com/srid/commonmark-wikilink.git";
        # Just to test heavy weight stuff
        # superposition = "https://github.com/juspay/superposition.git";
      };
    };
  };
}
