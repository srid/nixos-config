#!/bin/sh
set -e
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PLUGINS_NIX="${SCRIPT_DIR}/plugins.nix"
echo "Updating ${PLUGINS_NIX}"
set -x
nix run github:Fuuzetsu/jenkinsPlugins2nix -- \
    -p github-api \
    -p git \
    -p github-branch-source \
    -p workflow-aggregator \
    -p ssh-slaves  \
    -p configuration-as-code \
     > ${PLUGINS_NIX}
