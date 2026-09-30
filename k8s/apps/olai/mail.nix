# Mail reads the Kubernetes Secret supplied by ./secrets.nix.
# Restart olai after rotating credentials: environment values are read at startup.
{ ... }:
{
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
