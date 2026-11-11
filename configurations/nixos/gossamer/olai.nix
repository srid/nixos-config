# olai as a user service over this workstation's own Vault checkout, so the
# web view is http://127.0.0.1:7714 instead of the k3s deployment this repo
# used to run on naiveintent.
#
# Everything about serving comes from olai's own module options; the additions
# are the mail client's environment file (resolved from 1Password by
# `modules/home/services/onepassword.nix`), the ordering that guarantees it
# exists first, and OpenCode on the agent search path.
{ config, flake, lib, pkgs, ... }:

let
  # olai probes `OLAI_AGENT_PATH` (else the service's PATH) for the engines it
  # does not pin, and reads only OpenCode 2's wire. agent-distro pins that
  # build; it is referenced by the unit's environment only — not installed in
  # the user profile, so a shell's `opencode` is untouched.
  inherit (flake.inputs.agent-distro.harnesses.${pkgs.stdenv.hostPlatform.system})
    opencode;
in
{
  imports = [ flake.inputs.olai.homeManagerModules.default ];

  services.olai = {
    enable = true;
    dataDir = "${config.home.homeDirectory}/Vault";
    host = "127.0.0.1";
    port = flake.inputs.olai.lib.defaultPort; # 7714
    environmentFile = config.onepassword.envFiles.olai.path;
  };

  onepassword = {
    enable = true;
    envFiles.olai.secrets = {
      OLAI_MAIL_OAUTH_CLIENT = "op://Kubernetes/olai-mail/client_id";
      OLAI_MAIL_OAUTH_SECRET = "op://Kubernetes/olai-mail/client_secret";
    };
  };

  systemd.user.services.olai = {
    Unit = {
      Requires = [ config.onepassword.envFiles.olai.unit ];
      After = [ config.onepassword.envFiles.olai.unit ];
    };
    Service = {
      # Behind `tailscale serve` the browser's origin is not the Host olai
      # sees, and the websocket refuses unknown origins.
      Environment = [
        "OLAI_ALLOWED_ORIGINS=https://gossamer.rooster-blues.ts.net"
        # Replaces the probe's search path: exactly this, nothing ambient.
        "OLAI_AGENT_PATH=${lib.makeBinPath [ opencode ]}"
      ];
      # 1Password unreachable at login must not become the module's 1s restart
      # storm.
      RestartSec = lib.mkForce "30s";
    };
  };
}
