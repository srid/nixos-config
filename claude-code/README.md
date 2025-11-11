# Srid's Claude Code Configuration

## Nix module

- `nix/home-manager-module.nix` - Home-manager module for auto-wiring this directory layout.

### Usage

Import the home-manager module and set `autoWire.dir`:

```nix
{
  imports = [ ./claude-code/nix/home-manager-module.nix ];

  programs.claude-code = {
    enable = true;
    autoWire.dir = ./claude-code;
  };
}
```

