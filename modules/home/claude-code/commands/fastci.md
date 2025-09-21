---
name: fastci
description: Run fast CI for Haskell projects
---

This command runs a fast CI pipeline for Haskell projects using Cabal.

Steps:
1. Run `git add <FILE>` (*NOT* `git add .`) to add any untracked files added by you **DO NOT COMMIT** changes.
1. Fix all hlint warnings
1. Ensure it builds (`cabal build all`) *AND* fix all GHC warnings
1. Ensure tests pass: `cabal test all`
1. Run `pre-commit run -a` to autoformat.

This will:
- Clean up code by fixing compiler and linter warnings
- Validate formatting and pre-commit hooks
- Ensure the project builds successfully
- Run the full test suite

Prerequisites:
- Must be in a Haskell project directory with cabal.project or *.cabal files
- GHC, Cabal, and hlint must be available in the Nix devShell environment
- pre-commit must be configured for the project
