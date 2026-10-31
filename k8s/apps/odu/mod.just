host := 'pureintent'
namespace := 'odu-k3s'
deployment := 'odu'
container := 'odu'

import '../commands.just'

# The cache's published substituter URL and bucket public key.
use: (kubectl "-n" namespace "exec" ("deployment/" + deployment) "-c" container "--" "odu" "cache" "use" "main" "--origin" "http://127.0.0.1:18440")
