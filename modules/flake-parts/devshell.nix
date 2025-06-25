{ inputs, ... }:
{
  imports = [
    (inputs.git-hooks + /flake-module.nix)
  ];
  perSystem = { inputs', config, pkgs, ... }: {
    devShells.default = pkgs.mkShell {
      name = "nixos-config-shell";
      meta.description = "Dev environment for nixos-config";
      inputsFrom = [ config.pre-commit.devShell ];
      packages = with pkgs; [
        just
        nixd
        nix-output-monitor
        inputs'.agenix.packages.default
      ];
    };

    pre-commit.settings = {
      hooks.nixpkgs-fmt.enable = true;
    };
  };
}
