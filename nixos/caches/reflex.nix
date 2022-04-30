{ pkgs, ... }: {
  nix.binaryCachePublicKeys = [
    "ryantrinkle.com-1:JJiAKaRv9mWgpVAz8dwewnZe0AzzEAzPkagE9SP5NWI="
  ];
  nix.binaryCaches = [
    "https://nixcache.reflex-frp.org"
  ];
}
