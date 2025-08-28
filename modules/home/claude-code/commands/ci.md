---
name: ci
description: Run local CI using omnix
---

This command runs local continuous integration checks using omnix. 

**IMPORTANT**: `om ci` will run full CI, thus takes a lot of time. Use only when necessary.

Steps:
1. Run `om ci` to execute all CI checks locally

This will:
- Build all flake outputs, which includes:
    - Run tests  
    - Check formatting
    - Validate flake structure
    - Perform other CI validations

Prerequisites:
- Must be in a flake-enabled project directory
- omnix (`om`) must be available in the environment