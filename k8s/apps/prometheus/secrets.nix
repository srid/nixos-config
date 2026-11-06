# Prometheus' scrape credential: an odu metrics token, minted with
# `odu surface metrics token_mint` and held in 1Password's `Kubernetes` vault.
# External Secrets syncs the item's `token` field to the `odu-prometheus`
# Secret this app mounts as a bearer token file.
{ ... }:
{
  k8s.apps.prometheus.onepassword = {
    "odu-prometheus".token = "odu-prometheus/token";
  };
}
