# Shared constants for the Juspay `pu` / xyne-boxes tooling.
#
# Consumed by both layers: modules/home/work/juspay-run.nix (home-manager) and
# modules/nixos/linux/devbox.nix (NixOS). Plain attrs, not a module — `import`
# it rather than adding it to `imports`.
rec {
  # Hostname `pu` is not reachable through the jumphost SOCKS; xyne-boxes
  # defaults PU_HOST to `pu`, so pin the IP.
  # https://github.com/juspay/xyne-boxes/pull/14#issuecomment-4918563982
  puHost = "10.10.68.56";

  # The env every pu/xyne-boxes invocation needs in front of it.
  proxyEnv = socksPort: ''
    export ALL_PROXY=socks5://127.0.0.1:${toString socksPort}
    export HTTPS_PROXY=socks5://127.0.0.1:${toString socksPort}
    export HTTP_PROXY=socks5://127.0.0.1:${toString socksPort}
    export PU_HOST=${puHost}
  '';
}
