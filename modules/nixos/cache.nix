# kolu's OSS Attic cache (https://cache.kolu.dev/kolu-r2): substitute prebuilt
# kolu/olai/odu closures instead of building them. Same bucket and key kolu's
# own flake `nixConfig` advertises, so a build here matches a kolu checkout.
#
# Pushing is kolu's CI's job; hosts only substitute. The `oss_cache=1` flag in
# `just activate` still covers hosts that do not import this module (croissant,
# sheetal-codex, the darwin home env) via NIX_CONFIG.
{
  nix.settings = {
    extra-substituters = [ "https://cache.kolu.dev/kolu-r2" ];
    extra-trusted-public-keys = [
      "kolu-r2-1:7KmFrK05rVrnxkyZi9hJGnJJmRCpg87u6MUQIk7nokQ="
    ];
  };
}
