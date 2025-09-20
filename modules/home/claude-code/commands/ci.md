---
name: ci
description: Run local CI using omnix
---

This command runs the Nix project using omnix.

Steps:
1. Run `git add` to add any untracked files added by you **DO NOT COMMIT** changes.
2. Run `pre-commit run -a` to autoformat.
3. Run `om ci` to do a full build.

If `om ci` fails, fix all issues.

This will:
- Build all flake outputs, which includes:
    - Run tests
    - Check formatting
    - Validate flake structure
    - Perform other CI validations

Prerequisites:
- Must be in a flake-enabled project directory
- omnix (`om`) must be available in the environment
