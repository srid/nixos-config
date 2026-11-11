# 1Password for user services.
#
# One job: turn `op://` references into an `EnvironmentFile` any service's own
# module already reads. It declares no `ExecStart`, wraps no argv, and knows no
# consumer — the service keeps its own options (`package`, `dataDir`,
# `environmentFile`, …), and the only thing added to its unit is ordering.
#
#   onepassword.envFiles.olai.secrets = { VAR = "op://vault/item/field"; };
#
#   services.olai = {
#     enable = true;
#     environmentFile = config.onepassword.envFiles.olai.path;
#   };
#   systemd.user.services.olai.Unit = {
#     requires = [ config.onepassword.envFiles.olai.unit ];
#     after = [ config.onepassword.envFiles.olai.unit ];
#   };
#
# The resolving unit is a separate oneshot because a plain `EnvironmentFile=` is
# loaded *before* `ExecStartPre` (systemd 262: "Failed to load environment
# files" fails the spawn), so the file has to exist before the service starts.
# That separation has a second payoff: the service-account token is loaded as a
# credential of the oneshot only, so it is never in the service's environment —
# nor in that of the agents the service spawns.
#
# Rotation is a restart of the consuming unit: no rekey, no rebuild, no
# activation.
{ config, flake, lib, pkgs, ... }:

let
  cfg = config.onepassword;

  inherit (lib) mkEnableOption mkIf mkOption types;

  jq = lib.getExe pkgs.jq;
  op = lib.getExe cfg.package;

  # Literal paths only: `EnvironmentFile=` is not specifier-expanded.
  tokenFile = "${config.home.homeDirectory}/.config/agenix/${cfg.tokenSecret}";
  stateDir = "${config.home.homeDirectory}/.local/state/onepassword";

  # The bootstrap file is a Kubernetes Secret manifest for the clusters'
  # operator, so the token is one `jq` away from the file agenix installs.
  resolve = secrets: pkgs.writeShellScript "onepassword-env" ''
    set -euo pipefail
    umask 077
    export OP_SERVICE_ACCOUNT_TOKEN="$(${jq} -r \
      '.items[] | select(.kind == "Secret") | .stringData.token' \
      "$CREDENTIALS_DIRECTORY/op-token")"
    mkdir -p ${lib.escapeShellArg stateDir} "$(dirname "$1")"
    {
    ${lib.concatStrings (lib.mapAttrsToList
      (name: ref: ''  printf '${name}=%s\n' "$(${op} read ${lib.escapeShellArg ref})"'' + "\n")
      secrets)}
    } > "$1.tmp"
    mv -f "$1.tmp" "$1"
  '';
in
{
  imports = [ ../agenix.nix ];

  options.onepassword = {
    enable = mkEnableOption "1Password `op://` references as service environment files";

    package = lib.mkPackageOption pkgs "_1password-cli" { };

    tokenSecret = mkOption {
      type = types.str;
      default = "onepassword-token.json";
      description = ''
        Name of the agenix secret (and its `.age` file) holding the
        service-account token as a Kubernetes Secret manifest. The clusters'
        operator is bootstrapped from this same file.
      '';
    };

    envFiles = mkOption {
      type = types.attrsOf (types.submodule ({ name, ... }: {
        options = {
          secrets = mkOption {
            type = types.attrsOf types.str;
            example = {
              OLAI_MAIL_OAUTH_CLIENT = "op://Kubernetes/olai-mail/client_id";
            };
            description = "Environment variable -> `op://` reference";
          };

          path = mkOption {
            type = types.str;
            readOnly = true;
            default = "${stateDir}/${name}.env";
            description = "Absolute `EnvironmentFile=` for the consuming unit";
          };

          unit = mkOption {
            type = types.str;
            readOnly = true;
            default = "onepassword-env-${name}.service";
            description = "Oneshot that writes `path`; order the consumer after it";
          };
        };
      }));
      default = { };
      description = "Environment files resolved from 1Password at unit start";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    # `symlink = false` and a literal path: the module's default is the string
    # `${XDG_RUNTIME_DIR}/agenix/…`, which only the activation shell expands.
    age.secrets.${cfg.tokenSecret} = {
      file = flake.inputs.self + "/secrets/${cfg.tokenSecret}.age";
      path = tokenFile;
      symlink = false;
    };

    systemd.user.services = lib.mapAttrs'
      (name: envFile: lib.nameValuePair "onepassword-env-${name}" {
        Unit = {
          # The token is an agenix file. At login agenix.service is the thing
          # that creates it, and at switch time the first start can lose that
          # race ("Failed to set up credentials: No such file or directory"),
          # so the resolver owns the ordering rather than hoping.
          Requires = [ "agenix.service" ];
          After = [ "agenix.service" ];
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${resolve envFile.secrets} ${lib.escapeShellArg envFile.path}";
          LoadCredential = [ "op-token:${tokenFile}" ];
        };
        # Nothing pulls this in but the units that consume its file.
      })
      cfg.envFiles;
  };
}
