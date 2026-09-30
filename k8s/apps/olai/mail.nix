# Convert Google's OAuth JSON to a Kubernetes Secret only at activation time.
# Olai-specific adapter: agenix owns the downloaded Web OAuth JSON; K3s receives
# its two credentials through Secret references. Neither value enters the Nix store.
# Register https://olai-k3s.rooster-blues.ts.net/_olai/mail/oauth with Google.
{ config, flake, pkgs, ... }:
let
  namespace = config.k8s.apps.olai.namespace;
  directory = "/run/olai-mail";
  manifest = "${directory}/secret.json";
in
{
  age.secrets."olai-mail-oauth-client.json".file =
    flake.inputs.self + /secrets/olai-mail-oauth-client.json.age;

  system.activationScripts.olai-mail = {
    # Decryption precedes conversion. Write atomically with root-only permissions;
    # invalid/missing credentials fail validation without replacing the last manifest.
    deps = [ "agenix" ];
    text = ''
      (
        set -eu
        umask 077
        install -d -m 700 ${directory}
        temporary=$(mktemp ${directory}/.secret.XXXXXX)
        trap 'rm -f "$temporary"' EXIT
        ${pkgs.jq}/bin/jq -e --arg namespace ${namespace} -f ${./mail-secret.jq} \
          ${config.age.secrets."olai-mail-oauth-client.json".path} > "$temporary"
        mv "$temporary" ${manifest}
      )
    '';
  };

  # K3s links this runtime file. After rotating credentials, explicitly apply it
  # and restart the Deployment: environment variables are read only at pod creation.
  services.k3s.manifests.olai-mail.source = manifest;

  k8s.apps.olai.env = [
    {
      name = "OLAI_MAIL_OAUTH_CLIENT";
      valueFrom.secretKeyRef = { name = "olai-mail"; key = "client_id"; };
    }
    {
      name = "OLAI_MAIL_OAUTH_SECRET";
      valueFrom.secretKeyRef = { name = "olai-mail"; key = "client_secret"; };
    }
  ];
}
