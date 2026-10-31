# odu's secrets; External Secrets syncs each 1Password item (`Kubernetes`
# vault) to the Secret the Deployment reads.
{ ... }:
{
  k8s.apps.odu.onepassword = {
    # Cache root token. On a daemon with a door its only job is granting roles
    # (`odu auth grant`); it is not a principal.
    "odu-root-token".token = "odu-root-token/token";
    # The GitHub App behind sign-in (server mode). The ID goes into the
    # environment; the secret is read from a mounted file.
    "odu-github-app" = {
      client_id = "odu-github-app/client_id";
      client_secret = "odu-github-app/client_secret";
    };
  };
}
