# Host-side bits for kolu development on pureintent.
{ flake, ... }:

{
  # Dedicated account for kolu end-to-end remote-terminal tests.
  # Authorize srid (same machine) to `ssh kolu-e2e-remote@localhost` with his key.
  users.users.kolu-e2e-remote = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [ 
      # pureintent srid
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEnWriRB3c/G+O4/N5ALnOQBdBTp9LeGC6HNYTZCCGS2 srid@pureintent"
    ];
  };
}
