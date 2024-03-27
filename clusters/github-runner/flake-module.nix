{ config, self, lib, flake-parts-lib, ... }:

let
  inherit (flake-parts-lib)
    mkPerSystemOption;
  inherit (lib)
    types;
  cfg = config.distributed-github-runner;
in
{
  options.distributed-github-runner = {
    # TODO: Move to personal-repos?
    tokenFile = lib.mkOption {
      type = types.string;
      description = "The file containing the GitHub runner token";
    };
    runner-user = lib.mkOption {
      type = types.string;
      description = "The user to run the GitHub runner as";
      default = "github-runner";
    };
    runner-packages = lib.mkOption {
      type = types.listOf types.package;
      description = "Packages to install on the GitHub runners";
      default = [ ];
    };
    # NOTE: At some point, we want to support organization repositories as well.
    personal-repos = lib.mkOption {
      type = types.attrsOf (types.attrsOf (types.submodule {
        options = {
          num = lib.mkOption {
            type = types.int;
            description = "The number of runners to register for this repository";
            default = 1;
          };
        };
      }));
      description = "List of personal repositories to register the runner for";
      default = { };
    };
    outputs = {
      nixosModule = lib.mkOption {
        type = types.deferredModule;
        description = "The NixOS module to use for the GitHub runner";
        readOnly = true;
      };
    };
  };
}
