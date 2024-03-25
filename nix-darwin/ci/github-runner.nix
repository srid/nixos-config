{ flake, pkgs, lib, ... }:

{
  # Choose one or the other.
  imports = [
    ../../systems/parallels-vm/nix-darwin/use.nix
    # ./linux-builder.nix
  ];

  # TODO: Refactor this into a module, like easy-github-runners.nix
  services.github-runners =
    let
      srid = {
        common = {
          enable = true;
          replace = true;
          # TODO: Document instructions
          # - chmod og-rwx; chown github-runner
          # TODO: Use a secret manager. 1Password? https://github.com/LnL7/nix-darwin/issues/882
          # > OAuth app tokens and personal access tokens (classic) need the 
          # > admin:org scope to use this endpoint. If the repository is private, 
          # > the repo scope is also required.
          # https://docs.github.com/en/rest/actions/self-hosted-runners?apiVersion=2022-11-28#list-self-hosted-runners-for-an-organization
          tokenFile = "/run/github-token-ci";
          extraPackages = with pkgs; [
            # Standard nix tools
            nixci
            cachix

            # For nixos-flake
            sd

            # Tools already available in standard GitHub Runners; so we provide
            # them here:
            coreutils
            which
            jq
            # https://github.com/actions/upload-pages-artifact/blob/56afc609e74202658d3ffba0e8f6dda462b719fa/action.yml#L40
            (pkgs.runCommandNoCC "gtar" { } ''
              mkdir -p $out/bin
              ln -s ${lib.getExe pkgs.gnutar} $out/bin/gtar
            '')
          ];
        };
        repos = {
          emanote = {
            url = "https://github.com/srid/emanote";
            num = 2;
          };
          ema = {
            url = "https://github.com/srid/ema";
            num = 3;
          };
          dioxus-desktop-template = {
            url = "https://github.com/srid/dioxus-desktop-template";
            num = 2;
          };
          nixos-config = {
            url = "https://github.com/srid/nixos-config";
            num = 2;
          };
          nixci = {
            url = "https://github.com/srid/nixci";
            num = 2;
          };
          nixos-flake = {
            url = "https://github.com/srid/nixos-flake";
            num = 2 * 5;
          };
          haskell-flake = {
            url = "https://github.com/srid/haskell-flake";
            num = 2 * 7;
          };
          heist-extra = {
            url = "https://github.com/srid/heist-extra";
            num = 2;
          };
          unionmount = {
            url = "https://github.com/srid/unionmount";
            num = 2;
          };
        };
      };
    in
    lib.listToAttrs (lib.concatLists (lib.flip lib.mapAttrsToList srid.repos
      (k: { url, num }:
        lib.flip builtins.map (lib.range 1 num) (idx:
          let
            name = "${k}-${builtins.toString idx}";
            value = srid.common // {
              inherit url;
            };
          in
          lib.nameValuePair name value)
      )));
}
