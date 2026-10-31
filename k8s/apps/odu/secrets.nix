# odu's cache root token; External Secrets syncs the 1Password item to the
# Secret the Deployment reads. Administration only; the substituter serves
# without a valid token.
{ ... }:
{
  k8s.apps.odu.onepassword."odu-root-token".token = "odu-root-token/token";
}
