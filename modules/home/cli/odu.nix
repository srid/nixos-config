{
  xdg.configFile."odu/hosts.json".text = builtins.toJSON {
    aarch64-darwin = [
      "nix-infra@rasam.tail12b27.ts.net"
      "ci@petit"
    ];
    x86_64-linux = [
      "kolu-ci-1"
      "kolu-ci-2"
      "kolu-ci-3"
      "kolu-ci-4"
      "kolu-ci-5"
      "kolu-ci-6"
      "nix-infra@idli-01.tail12b27.ts.net"
      "localhost"
    ];
  };
}
