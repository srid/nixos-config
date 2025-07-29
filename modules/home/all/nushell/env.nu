$env.PATH = (
    $env.PATH
    | split row (char esep)
    | prepend $"/etc/profiles/per-user/($env.USER)/bin"
    | prepend $"/Users/($env.USER)/.nix-profile/bin"
    | prepend '/run/current-system/sw/bin/'
    | prepend "/nix/var/nix/profiles/default/bin"
)
