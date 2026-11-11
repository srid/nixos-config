# Each app selects its Kubernetes resources and imports the shared commands.
mod odu 'odu/mod.just'

# List app commands.
default:
    @just --list apps
