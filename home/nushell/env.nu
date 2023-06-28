let-env PATH = (
    $env.PATH
    | split row (char esep)
    | prepend $"/etc/profiles/per-user/($env.USER)/bin"
    | prepend '/run/current-system/sw/bin/'
    | prepend '/Applications/Docker.app/Contents/Resources/bin/'
)
