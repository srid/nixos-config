---
name: fastci
description: Run fast CI for Haskell projects
---

This command runs a fast CI pipeline for Haskell projects using Cabal.

Steps:
1. Run `git add` to add any untracked files added by you **DO NOT COMMIT** changes.
2. Fix all GHC warnings
3. Fix all hlint warnings
4. Run `pre-commit run -a` to autoformat.
5. Ensure it builds: `cabal build all`
6. Ensure tests pass: `cabal test all`

This will:
- Clean up code by fixing compiler and linter warnings
- Validate formatting and pre-commit hooks
- Ensure the project builds successfully
- Run the full test suite

Prerequisites:
- Must be in a Haskell project directory with cabal.project or *.cabal files
- GHC, Cabal, and hlint must be available in the Nix devShell environment
- pre-commit must be configured for the project
