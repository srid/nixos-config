namespace := 'olai-k3s'
deployment := 'olai'
container := 'olai'

import '../commands.just'

# Open a host-user shell in the live Vault; exit to unmount (host Nix builds work).
host-shell:
    bash ../host-shell.sh {{namespace}} olai-data Vault
