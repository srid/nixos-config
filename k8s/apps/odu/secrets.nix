# odu's secrets; External Secrets syncs each 1Password item (`Kubernetes`
# vault) to the Secret the Deployment reads.
{ ... }:
{
  k8s.apps.odu.onepassword = {
    # Cache root token. On a daemon with a door its only job is granting roles
    # (`odu surface auth user_grant`); it is not a principal.
    "odu-root-token".token = "odu-root-token/token";
    # The GitHub App behind sign-in (server mode). The ID goes into the
    # environment; the secret is read from a mounted file.
    "odu-github-app" = {
      client_id = "odu-github-app/client_id";
      client_secret = "odu-github-app/client_secret";
    };
    # The cloudflare row's API token (Zone:DNS:Edit, Zone:Read,
    # Account:Cloudflare Tunnel:Edit). Read from a mounted file.
    "odu-cloudflare".api_token = "odu-cloudflare/api_token";
    # The `r2` cache store's S3 keys (an R2 token scoped to its bucket). An
    # init container joins them into the one credentials file odu reads.
    "odu-r2" = {
      access_key_id = "odu-r2/access_key_id";
      secret_access_key = "odu-r2/secret_access_key";
    };
  };
}
