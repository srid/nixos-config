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
        "kolu-ci-1"
        "kolu-ci-2"
        "kolu-ci-3"
        "kolu-ci-4"
      ];
    };
  };
}
