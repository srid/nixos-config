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
        "kolu-ci-3"
        "kolu-ci-4"
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
