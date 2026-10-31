host := 'naiveintent'
namespace := 'olai-k3s'
deployment := 'olai'
container := 'olai'

import '../commands.just'

# Open a host-user shell in the live Vault (a bind mount, so run this on naiveintent itself); exit to unmount.
host-shell:
    bash ../host-shell.sh {{namespace}} olai-data Vault
