# Olai's field mappings; transport modules consume ordinary Kubernetes Secrets.
{ ... }:
{
  k8s.apps.olai.onepassword = {
    # GitHub repo deploy key for the private vault repository.
    "olai-ssh" = {
      id_ed25519 = "olai-git/private_key?ssh-format=openssh";
      "id_ed25519.pub" = "olai-git/public_key";
    };
    "olai-mail" = {
      client_id = "olai-mail/client_id";
      client_secret = "olai-mail/client_secret";
    };
  };
}
