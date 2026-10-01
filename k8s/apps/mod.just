# Each app selects its Kubernetes resources and imports the shared commands.
mod olai 'olai/mod.just'

# List app commands.
default:
    @just --list apps
