{
  # force: overwrite any pre-existing hosts.json (and stale .hm-backup) so
  # activation never fails on collision across NixOS / darwin / standalone HM.
  xdg.configFile."odu/hosts.json" = {
    force = true;
    text = builtins.toJSON {
      aarch64-darwin = [
        "ci@petit"
      ];

      x86_64-linux = [
        # OVH dedicated (configurations/nixos/croissant), over the tailnet.
        "ci@croissant"
        # `pu`-managed CI boxes; the ssh aliases come from ~/.pu-state/*/ssh_config.
        # Underlying pu machine names:
        #   kolu-ci-2  dev-x86-64-linux-17
        #   kolu-ci-3  dev-x86-64-linux-14
        #   kolu-ci-5  dev-x86-64-linux-05
        #   kolu-ci-6  idliv2
        #   kolu-ci-7  dev-x86-64-linux-04
        #   kolu-ci-8  dev-x86-64-linux-08
        #   kolu-ci-9  dev-x86-64-linux-05
        #   kolu-ci-10 dev-x86-64-linux-07
        "kolu-ci-2"
        "kolu-ci-3"
        "kolu-ci-5"
        "kolu-ci-6"
        "kolu-ci-7"
        "kolu-ci-8"
        "kolu-ci-9"
        "kolu-ci-10"
      ];
    };
  };
}
